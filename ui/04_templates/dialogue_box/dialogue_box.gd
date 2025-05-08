extends VBoxContainer

signal response_chosen(response)
signal closed

@export var open_sound: AudioStream
@export var skip_speed_factor = 2.0

@onready var source = $Source
@onready var content = $Content

var tween: Tween = null

enum State {
	ADVANCING,
	WAITING_FOR_INPUT,
	CLOSED
}

var current_state: State
var current_responses: Array[DialogueResponse] = []
var current_highlighted_response = 0
var lines_queue = []

var timer
var remaining_time

func _ready():
	self.close_dialogue()

func _unhandled_input(event):
	match current_state:
		State.ADVANCING:
			if (event.is_action_pressed(&"ui_accept") or event.is_action_pressed(&"ui_cancel")) and tween != null:
				tween.set_speed_scale(self.skip_speed_factor)
				self.get_viewport().set_input_as_handled()
			elif (event.is_action_released(&"ui_accept") or event.is_action_released(&"ui_cancel")) and tween != null:
				tween.set_speed_scale(1.0)
				self.get_viewport().set_input_as_handled()

		State.WAITING_FOR_INPUT:
			if self.current_responses.size() == 0:
				if event.is_action_pressed(&"ui_accept") or event.is_action_pressed(&"ui_cancel"):
					self.show_next_line()
					self.get_viewport().set_input_as_handled()
					UIService.play_focus_sound()
			else:
				if event.is_action_pressed(&"ui_accept"):
					self.choose_response()
					self.show_next_line()
					self.get_viewport().set_input_as_handled()
					UIService.play_interaction_sound()
				if event.is_action_pressed(&"ui_down"):
					self.point_to_response(posmod(self.current_highlighted_response + 1, self.current_responses.size()))
					self.get_viewport().set_input_as_handled()
					UIService.play_focus_sound()
				elif event.is_action_pressed(&"ui_up"):
					self.point_to_response(posmod(self.current_highlighted_response - 1, self.current_responses.size()))
					self.get_viewport().set_input_as_handled()
					UIService.play_focus_sound()
				elif event.is_action_pressed(&"ui_cancel"):
					self.point_to_response(0)
					self.get_viewport().set_input_as_handled()
					UIService.play_focus_sound()


func queue_dialogue_lines(dialogue_lines: Array):
	self.lines_queue.append_array(dialogue_lines)
	
	if current_state == State.CLOSED :
		self.open_dialogue()

func show_next_line():
	content.set_advance_indicator_visibility(false)
	if lines_queue.is_empty():
		self.close_dialogue()
	else:
		var line = lines_queue[0]
		lines_queue.remove_at(0)
		
		if "responses" in line:
			self.set_responses(line)
			
		else:
			await self.set_text(line)
			return null


func set_responses(line: Dictionary):
	self.current_state = State.ADVANCING
	self.current_responses = line["responses"]
	
	source.set_text(line["text"])
	content.set_text("")
	self.point_to_response(0)
	self.remaining_time = 0.2
	
	await self.get_tree().create_timer(0.2, false).timeout
	
	self.timer = null
	current_state = State.WAITING_FOR_INPUT

	
func point_to_response(index: int):
	self.current_highlighted_response = index
	var option_lines = range(self.current_responses.size()).map(
		func(i):
				var text = self.current_responses[i].text
				if i == index:
					text = "> " + text
				return text
	)
	content.set_text("\n".join(option_lines))
	content.set_visible_ratio(1.0)
	
func choose_response():
	var response = self.current_responses[self.current_highlighted_response]
	self.current_responses = []
	self.current_highlighted_response = 0
	self.response_chosen.emit(response)

func set_text(line: Dictionary):
	source.set_text(line["source"])
	current_state = State.ADVANCING
	self.tween = DialogueService.tween_text(content, line["text"])
	await tween.finished
	
	# During the await, the content could have been paused and skipped (so it was closed), 
	# so we re-check
	if self.current_state == State.ADVANCING:
		content.set_advance_indicator_visibility(true)
		current_state = State.WAITING_FOR_INPUT
	
func open_dialogue():
	self.set_process_unhandled_input(true)
	UIService.play_focus_sound()
	self.show()
	self.show_next_line()
	
func close_dialogue():
	self.set_process_unhandled_input(false)
	self.hide()
	self.current_state = State.CLOSED
	self.closed.emit()

func set_dialogue_alignment(new_alignment: BoxContainer.AlignmentMode):
	if self.alignment == new_alignment:
		return
	self.alignment = new_alignment
	
	if self.alignment == ALIGNMENT_BEGIN:
		self.move_child(source, 1)
	else:
		self.move_child(source, 0)
	
func pause():
	match current_state:
		State.ADVANCING:
			self.set_process_unhandled_input(false)
		State.WAITING_FOR_INPUT:
			self.set_process_unhandled_input(false)
		State.CLOSED:
			pass

func resume():
	match current_state:
		State.ADVANCING:
			self.set_process_unhandled_input(true)
		State.WAITING_FOR_INPUT:
			self.set_process_unhandled_input(true)
		State.CLOSED:
			pass

func skip():
	self.lines_queue = []
	self.current_responses = []
	match current_state:
		State.ADVANCING:
			if tween != null:
				tween.finished.emit()
				tween.kill()
		State.WAITING_FOR_INPUT:
			pass
		State.CLOSED:
			pass
	self.close_dialogue()

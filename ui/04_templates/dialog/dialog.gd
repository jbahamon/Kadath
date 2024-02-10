extends VBoxContainer

signal response_chosen(response)
signal closed

@export var characters_per_second = 15.0
@export var skip_speed_factor = 2.0

@onready var source = $DialogSource
@onready var box = $DialogBox

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

func _ready():
	self.close_dialog()

func _unhandled_input(event):
	match current_state:
		State.ADVANCING:
			if event.is_action_pressed("ui_accept") and tween != null:
				tween.set_speed_scale(self.skip_speed_factor)
			elif event.is_action_released("ui_accept") and tween != null:
				tween.set_speed_scale(1.0)

		State.WAITING_FOR_INPUT:
			if event.is_action_pressed("ui_accept"):
				if self.current_responses.size() > 0:
					self.choose_response()
				self.show_next_line()
			elif event.is_action_pressed("ui_down") and self.current_responses.size() > 0:
				self.point_to_response(posmod(self.current_highlighted_response + 1, self.current_responses.size()))
			elif event.is_action_pressed("ui_up") and self.current_responses.size() > 0:
				self.point_to_response(posmod(self.current_highlighted_response - 1, self.current_responses.size()))
			elif event.is_action_pressed("ui_cancel") and self.current_responses.size() > 0:
				self.point_to_response(0)
	
	get_viewport().set_input_as_handled()

func queue_dialog_lines(dialog_lines: Array):
	self.lines_queue.append_array(dialog_lines)
	
	if current_state == State.CLOSED :
		self.open_dialog()

func show_next_line():
	box.set_advance_indicator_visibility(false)
	if lines_queue.is_empty():
		self.close_dialog()
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
	box.set_text("")
	self.point_to_response(0)
	await self.get_tree().create_timer(0.2).timeout
	current_state = State.WAITING_FOR_INPUT

func point_to_response(index: int):
	self.current_highlighted_response = index
	var option_lines = []
	
	for i in range(self.current_responses.size()):
		var text = self.current_responses[i].text
		if i == index:
			text = "> " + text
		option_lines.append(text)
			
	box.set_text("\n".join(option_lines))
	box.set_visible_ratio(1.0)
func choose_response():
	
	var response = self.current_responses[self.current_highlighted_response]
	self.current_responses = []
	self.current_highlighted_response = 0
	self.emit_signal("response_chosen", response)

func set_text(line: Dictionary):
	source.set_text(line["source"])
	box.set_text(line["text"])
	current_state = State.ADVANCING
	
	self.tween = self.get_tree().create_tween()
	var time = box.get_total_character_count() / self.characters_per_second
	tween.tween_method(self.box.set_visible_ratio, 0.0, 1.0, time)
	tween.play()
	await tween.finished
	
	box.set_advance_indicator_visibility(true)
	current_state = State.WAITING_FOR_INPUT

func open_dialog():
	self.set_process_unhandled_input(true)
	self.show()
	self.show_next_line()
	
func close_dialog():
	self.set_process_unhandled_input(false)
	self.hide()
	self.current_state = State.CLOSED
	self.emit_signal("closed")

func set_dialog_alignment(new_alignment: BoxContainer.AlignmentMode):
	if self.alignment == new_alignment:
		return
	self.alignment = new_alignment
	
	if self.alignment == ALIGNMENT_BEGIN:
		self.move_child(source, 1)
	else:
		self.move_child(source, 0)
	
	
	
	
	

extends VBoxContainer

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
				self.show_next_line()
	
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
		source.set_text(line["source"])
		box.set_text(line["text"])
		current_state = State.ADVANCING
		
		self.tween = self.get_tree().create_tween()
		var time = box.get_total_character_count() / self.characters_per_second
		tween.tween_method(Callable(self.box, "set_visible_ratio"), 0.0, 1.0, time)
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
	emit_signal("closed")

func set_dialog_alignment(new_alignment: BoxContainer.AlignmentMode):
	if self.alignment == new_alignment:
		return
	self.alignment = new_alignment
	
	if self.alignment == ALIGNMENT_BEGIN:
		self.move_child(source, 1)
	else:
		self.move_child(source, 0)
	
	
	
	
	

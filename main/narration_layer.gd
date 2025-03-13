extends CanvasLayer

signal advance

const FADE_TIME = 1.5
@export var transition_time: float = 1.0

@onready var label = $VBox/Margin/NarrationText
@onready var advance_label = $MarginContainer/VBoxContainer/Label

var should_skip = false
var fade_tween = null

func _ready() -> void:
	self.set_process_unhandled_input(false)

func narrate(text):
	self.should_skip = false
	advance_label.hide()
	label.modulate = Color.TRANSPARENT
	label.text = text
	self.visible = true
	
	self.fade_tween = get_tree().create_tween()
	self.fade_tween.tween_property(label, "modulate", Color.WHITE, FADE_TIME)
	await self.fade_tween.finished
	
	if self.should_skip:
		self.visible = false
		return
	
	var advance_input = OS.get_keycode_string(InputMap.action_get_events(&"ui_accept")[0].keycode)
	advance_label.text = "[%s] Advance" % advance_input
	advance_label.show()
	self.set_process_unhandled_input(true)
	await self.advance
	self.set_process_unhandled_input(false)
	
	advance_label.hide()
	self.fade_tween = get_tree().create_tween()
	self.fade_tween.tween_property(label, "modulate", Color.TRANSPARENT, FADE_TIME)
	await self.fade_tween.finished
	
	self.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		self.advance.emit()
	
func skip():
	self.should_skip = true
	self.set_process_unhandled_input(false)
	if self.fade_tween != null:
			self.fade_tween.finished.emit()
			self.fade_tween.kill()
	
	self.advance.emit()

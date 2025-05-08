extends Control

signal done

@onready var text_speed: Slider = $HBoxContainer/UISliders/TextSpeedSlider
@onready var settings_menu = get_node("../../..")

func _ready() -> void:
	self.set_process_unhandled_input(false)
	self.text_speed.focus_entered.connect(self.on_slider_focused.bind("Change dialogue text speed."))
	self.text_speed.focus_exited.connect(UIService.end_text_speed_demo)
	self.text_speed.set_value_no_signal(SettingsService.text_speed)

func on_slider_focused(help_text):
	self.settings_menu.on_slider_focused(help_text)

func update_text_speed(value):
	UIService.play_focus_sound()
	UIService.start_text_speed_demo()
	SettingsService.update_text_speed(value)

func on_grab_focus():
	text_speed.grab_focus()
	self.set_process_unhandled_input(true)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		self.done.emit()
		self.get_viewport().set_input_as_handled()
		self.set_process_unhandled_input(false)

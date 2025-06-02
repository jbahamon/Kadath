extends Control

signal exit
var focus_in_tree = false

@onready var block_mouse_popup: Popup = $Popups/BlockClicksPopup
@onready var input_popup: Popup = $Popups/ListenForInputPopup
@onready var audio_video = $HBoxContainer/Content/AudioVideo
@onready var interface = $HBoxContainer/Content/Interface
@onready var controls = $HBoxContainer/Content/Controls

@onready var current_submenu = self.audio_video

@onready var audio_video_button: Button = $HBoxContainer/Categories/AudioVideo
@onready var interface_button = $HBoxContainer/Categories/Interface
@onready var controls_button = $HBoxContainer/Categories/Controls

var categories_button_group = ButtonGroup.new()

@onready var first_item_focus_binding 
func _init():
	self.set_process_unhandled_input(false)
	self.first_item_focus_binding = self.focus_submenu.bind(audio_video, "Change volume and toggle certain effects.")
	
func _ready():
	input_popup.popup_window = false
	audio_video_button.pressed.connect(self.toggle_submenu.bind(audio_video))
	interface_button.pressed.connect(self.toggle_submenu.bind(interface))
	controls_button.pressed.connect(self.toggle_submenu.bind(controls))

	audio_video_button.focus_entered.connect(self.first_item_focus_binding)
	interface_button.focus_entered.connect(self.focus_submenu.bind(interface, "Set text speed and other interface properties."))
	controls_button.focus_entered.connect(self.focus_submenu.bind(controls, "Set the game's controls and other behaviors."))
	
	self.audio_video_button.button_group = self.categories_button_group
	self.interface_button.button_group = self.categories_button_group
	self.controls_button.button_group = self.categories_button_group
	
func _unhandled_input(event):
	if event.is_action_pressed(&"ui_cancel") and self.is_focus_on_categories():
		self.exit.emit()
		self.get_viewport().set_input_as_handled()
		self.set_process_unhandled_input(false)

func show_menu():
	self.show()
	self.on_grab_focus()
	self.set_process_unhandled_input(true)

func hide_menu():
	self.hide()
	self.set_process_unhandled_input(false)

func update_menu():
	pass

func on_grab_focus():
	self.audio_video_button.focus_entered.disconnect(self.first_item_focus_binding)
	self.audio_video_button.grab_click_focus()
	self.audio_video_button.grab_focus()
	self.audio_video_button.focus_entered.connect(self.first_item_focus_binding)
	self.set_process_unhandled_input(true)
	
func update_run_behavior(value):
	SettingsService.update_run_behavior(value)

func on_slider_focused(help_text):
	UIService.play_focus_sound()
	UIService.set_menu_help(
		help_text,
		"[{ui_up}]/[{ui_down}]: Move [{ui_left}]/[{ui_right}]: Increase/Decrease [{ui_cancel}]: Return"
	)

func on_checkbox_focused(help_text):
	UIService.set_menu_help(
		help_text,
		"[{ui_up}]/[{ui_down}]: Move [{ui_cancel}]: Return [{ui_accept}]: Toggle"
	)

func on_toggle_focused(help_text):
	UIService.set_menu_help(
		help_text,
		"[{ui_up}]/[{ui_down}]/[{ui_left}]/[{ui_right}]: Move [{ui_cancel}]: Return [{ui_accept}]: Select"
	)

func focus_submenu(submenu, help_text):
	UIService.set_menu_help(
		help_text,
		"[{ui_up}]/[{ui_down}]: Move [{ui_cancel}]: Return [{ui_accept}]: Select"
	)

	self.current_submenu.hide()
	submenu.show()
	self.current_submenu = submenu

func toggle_submenu(submenu):
	submenu.on_grab_focus()

func _on_controls_input_request(action: String, label: String) -> void:
	input_popup.update_action(action, label)
	input_popup.popup_centered()

func is_focus_on_categories():
	return self.categories_button_group.get_buttons().any(func(button): return button.has_focus())

func _on_content_done() -> void:
	self.categories_button_group.get_pressed_button().grab_focus()
	self.categories_button_group.get_pressed_button().set_pressed_no_signal(false)

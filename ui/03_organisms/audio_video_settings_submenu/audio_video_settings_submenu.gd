extends Control

signal done

@export var sfx_sample: AudioStream

@onready var music_volume: Slider = $HBoxContainer/VolumeSliders/MusicVolumeSlider
@onready var sfx_volume: Slider = $HBoxContainer/VolumeSliders/SFXVolumeSlider
@onready var ui_volume: Slider = $HBoxContainer/VolumeSliders/UIVolumeSlider

@onready var enable_shake_checkbox: CheckBox = $VideoCheckBoxes/EnableShake
@onready var enable_flash_checkbox: CheckBox = $VideoCheckBoxes/EnableFlash

@onready var settings_menu = get_node("../../..")

func _ready() -> void:
	self.set_process_unhandled_input(false)
	self.music_volume.set_value_no_signal(SettingsService.volume[&"BGM"])
	self.sfx_volume.set_value_no_signal(SettingsService.volume[&"SFX"])
	self.ui_volume.set_value_no_signal(SettingsService.volume[&"UI"])
	
	self.music_volume.focus_entered.connect(self.on_slider_focused.bind("Raise or lower the music volume."))
	self.sfx_volume.focus_entered.connect(self.on_slider_focused.bind("Raise or lower the sound effect volume."))
	self.ui_volume.focus_entered.connect(self.on_slider_focused.bind("Raise or lower the interface sound volume."))
	
	self.enable_shake_checkbox.set_pressed_no_signal(SettingsService.enable_screen_shake)
	self.enable_flash_checkbox.set_pressed_no_signal(SettingsService.enable_flashing)
	
	self.enable_shake_checkbox.focus_entered.connect(self.on_checkbox_focused.bind("Enable/disable camera shaking in battles and cutscenes."))
	self.enable_flash_checkbox.focus_entered.connect(self.on_checkbox_focused.bind("Enable/disable camera flashing in battles and cutscenes."))
	
	self.enable_shake_checkbox.pressed.connect(UIService.play_interaction_sound)
	self.enable_flash_checkbox.pressed.connect(UIService.play_interaction_sound)
	

func update_sfx_volume(value):
	FXService.play_sfx(self.sfx_sample)
	SettingsService.update_volume(&"SFX", self.sfx_volume.value)

func update_music_volume(value):
	SettingsService.update_volume(&"BGM", self.music_volume.value)

func update_ui_volume(value):
	UIService.play_focus_sound()
	SettingsService.update_volume(&"UI", self.ui_volume.value)

func on_slider_focused(help_text):
	self.settings_menu.on_slider_focused(help_text)

func on_checkbox_focused(help_text) -> void:
	self.settings_menu.on_checkbox_focused(help_text)

func update_enable_shake(toggled_on: bool) -> void:
	SettingsService.update_enable_screen_shake(toggled_on)

func update_enable_flash(toggled_on: bool) -> void:
	SettingsService.update_enable_flashing(toggled_on)

func on_grab_focus():
	music_volume.grab_focus()
	self.set_process_unhandled_input(true)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		self.done.emit()
		self.get_viewport().set_input_as_handled()
		self.set_process_unhandled_input(false)

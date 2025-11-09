extends Node

var open_popup_sound: AudioStream = preload("res://sound/fx/whoosh/Sharp Short - Lunar Wire.wav")
var close_popup_sound: AudioStream = preload("res://sound/fx/whoosh/Sharp Short - Lunar Wire.wav")

var focus_sound: AudioStream = preload("res://sound/ui/blops/High - Kenney.wav")
var pressed_sound: AudioStream = preload("res://sound/ui/interaction/Button Press - zipdisq.wav")
var error_sound: AudioStream = preload("res://sound/ui/interaction/Error - Leohpaz.wav")

var help_bar
var menu_popup: Popup
var save_popup: Popup
var popup_layer: CanvasLayer
var control_player: AudioStreamPlayer
var notification_player: AudioStreamPlayer

var opening_menu = false

var text_speed_tween = null

const PROMPT_WAIT_TIME = 2.0

func _init():
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _ready():
	self.set_process_unhandled_input(false)
	self.get_tree().node_added.connect(self.connect_to_button)
	connect_buttons(get_tree().root)
	
func initialize_basic(
	init_help_bar,
	init_control_player: AudioStreamPlayer, 
	init_notification_player: AudioStreamPlayer
):
	
	self.help_bar = init_help_bar
	self.control_player = init_control_player
	self.notification_player = init_notification_player
	
func initialize(
	init_popup_layer: CanvasLayer, 
	init_menu_popup: Popup, 
	init_save_popup: Popup, 
	init_control_player, init_notification_player
):
	self.initialize_basic(
		init_menu_popup.help_bar, 
		init_control_player, 
		init_notification_player,
	)
	
	init_menu_popup.popup_window = false
	init_save_popup.popup_window = false
	
	self.popup_layer = init_popup_layer
	self.menu_popup = init_menu_popup
	self.save_popup = init_save_popup
	
	self.save_popup.popup_hide.connect(self.on_close_popup)
	self.menu_popup.popup_hide.connect(self.on_close_popup)
	
func connect_buttons(root):
	for child in root.get_children():
		if child is BaseButton:
			connect_to_button(child)
		connect_buttons(child)

func connect_to_button(node: Node):
	if node is BaseButton and not node.focus_entered.is_connected(self.play_focus_sound):
		node.focus_entered.connect(self.play_focus_sound)

func play_focus_sound():
	if opening_menu:
		return
	self.control_player.stream = focus_sound
	self.control_player.play()
	
func on_button_pressed():
	if opening_menu:
		return
	self.control_player.stream = pressed_sound
	self.control_player.play()

func on_close_popup():
	self.notification_player.stream = close_popup_sound
	self.notification_player.play()

func exit():
	self.get_tree().node_added.disconnect(self.connect_to_button)
	self.popup_layer = null
	self.menu_popup = null
	self.save_popup = null
	self.notification_player = null
	
func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_menu"): 
		self.opening_menu = true
		self.menu_popup.get_child(0).initialize()
		self.handle_popup(menu_popup, true, 1)
		self.get_viewport().set_input_as_handled()
		self.opening_menu = false

func play_notification(sound):
	self.notification_player.stream = sound
	self.notification_player.play()
	return self.notification_player

func show_save_menu(save_spot_name) -> void:
	save_popup.set_spot_name(save_spot_name)
	self.handle_popup(save_popup, true, 1)
	
	
func handle_popup(popup_node: Window, pause_tree, ratio=null, play_sound=true):
	if pause_tree:
		InputService.enter_menu_mode()
	
	if play_sound:
		self.notification_player.stream = open_popup_sound
		self.notification_player.play()
	
	if ratio == null:
		popup_node.popup_centered_clamped(Vector2.ONE, 0.2)
	else:
		popup_node.popup_centered_ratio(ratio)
		
	await popup_node.popup_hide
	
	if pause_tree:
		InputService.exit_menu_mode()

func start_text_speed_demo():
	if self.text_speed_tween != null:
		self.text_speed_tween.stop()
	
	self.help_bar.set_visible_ratio(0.0)
		
	self.text_speed_tween = DialogueService.tween_text(
		self.help_bar,
		"Change the UI text speed",
	)
	
func end_text_speed_demo():
	self.help_bar.set_visible_ratio(1.0)
	if self.text_speed_tween == null:
		return
		
	self.text_speed_tween.stop()
	self.text_speed_tween = null
	
func set_menu_help(help_text: String, controls_text: String):
	self.help_bar.help_label.text = help_text
	self.help_bar.controls_label.text = controls_text.format(VarsService.strings)

func play_interaction_sound():
	return self.play_notification(self.pressed_sound)

func play_error_sound():
	return self.play_notification(self.error_sound)

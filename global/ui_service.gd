extends Node

var open_popup_sound: AudioStream = preload("res://sound/fx/whoosh/Sharp Short - Lunar Wire.wav")
var close_popup_sound: AudioStream = preload("res://sound/fx/whoosh/Sharp Short - Lunar Wire.wav")

var focus_sound: AudioStream = preload("res://sound/ui/blops/High - Kenney.wav")
var pressed_sound: AudioStream = preload("res://sound/ui/interaction/Button Press - zipdisq.wav")
var menu_popup: Popup
var save_popup: Popup
var popup_layer: CanvasLayer
var control_player: AudioStreamPlayer
var notification_player: AudioStreamPlayer

var opening_menu = false

const PROMPT_WAIT_TIME = 2.0

func _init():
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _ready():
	self.set_process_unhandled_input(false)
	
func initialize(init_popup_layer: CanvasLayer, init_menu_popup: Popup, init_save_popup: Popup, init_control_player, init_notification_player):
	init_menu_popup.popup_window = false
	init_save_popup.popup_window = false
	
	self.popup_layer = init_popup_layer
	self.menu_popup = init_menu_popup
	self.save_popup = init_save_popup
	self.control_player = init_control_player
	self.notification_player = init_notification_player
	
	self.menu_popup.popup_hide.connect(self.on_close_popup)
	self.get_tree().node_added.connect(self.connect_to_button)
	connect_buttons(get_tree().root)
	
func connect_buttons(root):
	for child in root.get_children():
		if child is BaseButton:
			connect_to_button(child)
		connect_buttons(child)

func connect_to_button(node: Node):
	if node is BaseButton:
		node.focus_entered.connect(self.play_focus_sound)
		# node.pressed.connect(self.on_button_pressed)

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
	self.get_tree().node_added.disconnect(self.on_node_added)
	self.popup_layer = null
	self.menu_popup = null
	self.save_popup = null
	self.notification_player = null
	self.focus_player = null
	
func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_menu"): 
		self.opening_menu = true
		self.menu_popup.get_child(0).initialize()
		self.__handle_popup(menu_popup, true, 1)
		self.get_viewport().set_input_as_handled()
		self.opening_menu = false
		
func show_popup(popup_node: Window, pause_tree=true):
	self.popup_layer.add_child(popup_node)
	await self.__handle_popup(popup_node, pause_tree)
	self.popup_layer.call_deferred("remove_child", popup_node)

func play_notification(sound):
	self.notification_player.stream = sound
	self.notification_player.play()
	return self.notification_player

func show_save_menu() -> void:
	self.__handle_popup(menu_popup, true)
	
func __handle_popup(popup_node: Window, pause_tree, ratio=null):
	if pause_tree:
		InputService.enter_menu_mode()
	
	self.notification_player.stream = open_popup_sound
	self.notification_player.play()
	
	if ratio == null:
		popup_node.popup_centered()
	else:
		popup_node.popup_centered_ratio(ratio)
		
	await popup_node.popup_hide
	
	if pause_tree:
		InputService.exit_menu_mode()

func set_menu_help(help_text: String, controls_text: String):
	menu_popup.help_label.text = help_text
	menu_popup.controls_label.text = controls_text.format(VarsService.strings)

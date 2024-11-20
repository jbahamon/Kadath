extends Node

var menu_popup: Popup
var save_popup: Popup
var popup_layer: CanvasLayer

func _init():
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _ready():
	self.set_process_unhandled_input(false)
	
func initialize(init_popup_layer: CanvasLayer, init_menu_popup: Popup, init_save_popup: Popup):
	init_menu_popup.popup_window = false
	init_save_popup.popup_window = false
	
	self.popup_layer = init_popup_layer
	self.menu_popup = init_menu_popup
	self.save_popup = init_save_popup

func exit():
	self.popup_layer = null
	self.menu_popup = null
	self.save_popup = null
	
func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_menu"): 
		self.menu_popup.get_child(0).initialize()
		self.__handle_popup(menu_popup, true, 1)
		self.get_viewport().set_input_as_handled()
		
func show_popup(popup_node: Window, pause_tree=true):
	self.popup_layer.add_child(popup_node)
	await self.__handle_popup(popup_node, pause_tree)
	self.popup_layer.call_deferred("remove_child", popup_node)

func show_save_menu() -> void:
	self.__handle_popup(menu_popup, true)
	
func __handle_popup(popup_node: Window, pause_tree, ratio=null):
	if pause_tree:
		InputService.enter_menu_mode()
	
	if ratio == null:
		popup_node.popup_centered()
	else:
		popup_node.popup_centered_ratio(ratio)
		
	await popup_node.popup_hide
	
	if pause_tree:
		InputService.exit_menu_mode()

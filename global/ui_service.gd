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
	
func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_menu"): 
		self.menu_popup.get_child(0).initialize()
		self.__handle_popup(menu_popup)
		
func show_popup(popup_node: Popup):
	self.popup_layer.add_child(popup_node)
	await self.__handle_popup(popup_node)
	self.popup_layer.remove_child(popup_node)

func show_save_menu() -> void:
	self.__handle_popup(menu_popup)
	
func __handle_popup(popup_node: Popup):
	var content_node: Node = popup_node.get_child(0)
	InputService.enter_menu_mode(content_node)
	
	popup_node.popup_centered_ratio(1)
	await popup_node.popup_hide
	InputService.exit_menu_mode(content_node)


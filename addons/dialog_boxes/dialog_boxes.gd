@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("DialogBox", "CanvasLayer", preload("dialog_box_canvas_layer.gd"), preload("icon.png"))


func _exit_tree():
	remove_custom_type("DialogBox")

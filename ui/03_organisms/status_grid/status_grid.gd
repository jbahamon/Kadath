extends Node2D

var StatusIcon = preload("res://ui/02_molecules/status_icon/status_icon.tscn")

@onready var container = $GridContainer

func set_statuses(statuses: Array):
	self.clear()
	
	for status in statuses:
		if status.icon != null:
			var new_icon = StatusIcon.instantiate()
			new_icon.set_icon(status.icon)
			container.add_child(new_icon)
		
	container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE)
	container.position.y = -50
	container.z_index = 2
	

func clear():
	var children = container.get_children()
	
	for child in children:
		container.remove_child(child)
		child.queue_free()
	
	
	

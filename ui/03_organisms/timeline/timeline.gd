extends PanelContainer

var TimelineItem = preload("res://ui/02_molecules/timeline_item/timeline_item.tscn")

@onready var current_actor_icon = $VBoxContainer/HBoxContainer/CurrentActorIcon
@onready var container = $VBoxContainer/Container

func highlight(highlighted_items):
	if current_actor_icon.battle_actor_id in highlighted_items:
		current_actor_icon.highlight()
	else:
		current_actor_icon.stop_highlight()
	
	for timeline_item in self.container.get_children():
		if timeline_item.battle_actor_id in highlighted_items:
			timeline_item.highlight()
		else:
			timeline_item.stop_highlight()
	
func update_preview(current_actor, next_actors: Array):
	self.show()
	self.current_actor_icon.set_actor(current_actor)
	
	var icons_to_remove = self.container.get_child_count() - next_actors.size()
	
	if icons_to_remove > 0:
		for _i in range(icons_to_remove):
			var item = self.get_child(0)
			self.container.remove_child(item)
			item.queue_free()
	elif icons_to_remove < 0:
		for _i in range(-icons_to_remove):
			var new_item = TimelineItem.instantiate()
			self.container.add_child(new_item) 
	
	var i = 0
	for timeline_item in self.container.get_children():
		timeline_item.set_actor(next_actors[i])
		i += 1

extends HBoxContainer

var TimelineItem = preload("res://ui/02_molecules/timeline_item/timeline_item.tscn")

func highlight(highlighted_items):
	for timeline_item in self.get_children():
		if timeline_item.actor_id in highlighted_items:
			timeline_item.highlight()
		else:
			timeline_item.stop_highlight()
	
func update_preview(preview: Array):
	var icons_to_remove = self.get_child_count() - preview.size()
	
	var text_preview = "Preview: "
	for item in preview:
		text_preview = text_preview + item.display_name + " "
	
	print(text_preview)
	if icons_to_remove > 0:
		for _i in range(icons_to_remove):
			var item = self.get_child(0)
			self.remove_child(item)
			item.queue_free()
	elif icons_to_remove < 0:
		for _i in range(-icons_to_remove):
			var new_item = TimelineItem.instantiate()
			self.add_child(new_item) 
	
	var i = 0
	for timeline_item in self.get_children():
		timeline_item.set_actor(preview[i])
		i += 1
		
	self.visible = true


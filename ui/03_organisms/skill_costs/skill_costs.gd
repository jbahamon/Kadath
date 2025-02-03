extends PanelContainer

@onready var grid = $GridContainer

func update_costs(costs: Array):
	if costs.size() == 0:
		self.hide()
		return
	
	var current_children = self.grid.get_child_count() - 2
	while current_children > costs.size() * 2:
		self.grid.remove_child(self.grid.get_child(2 + current_children - 1))
		current_children -= 1
		
	while current_children < costs.size() * 2:
		var texture = TextureRect.new()
		texture.custom_minimum_size = Vector2(32,32)
		self.grid.add_child(texture)
		
		var label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		self.grid.add_child(label)
		current_children += 2
		
	for i in range(costs.size()):
		var actor = costs[i][0]
		var cost = costs[i][1]
		
		self.grid.get_child(2 * (i + 1)).texture = actor.icon
		var label = self.grid.get_child(2 * (i + 1) + 1)
		label.text = "   %s" % cost
		
	self.show()
	

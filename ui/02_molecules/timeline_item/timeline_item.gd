extends PanelContainer

const highlight_material = preload("res://utils/material/highlight.tres")

@onready var icon: TextureRect = $TextureRect
@onready var label: Label = $Label

var battle_actor_id

func highlight():
	self.icon.material = self.highlight_material

func stop_highlight():
	self.icon.material = null
	
func set_actor(actor):
	var id = actor.get("instance_id")
	self.label.text = id if id != null else ""
	self.icon.texture = actor.icon
	self.battle_actor_id = actor.in_battle_id

extends Node2D

@onready var area: Area2D = $Area2D

func reset():
	self.position = Vector2.ZERO

func get_actors_at(position: Vector2) -> Array:
	self.global_position = position
	self.area.set_deferred("monitoring", true)
	
	var tree = get_tree()
	await tree.process_frame
	await tree.physics_frame
	await tree.physics_frame
	
	var hitboxes = self.area.get_overlapping_areas()
	
	var actors = []
	for hitbox in hitboxes:
		actors.append(hitbox.get_parent())
		
	return actors

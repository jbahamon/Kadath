extends Node2D

@onready var area: Area2D = $Area2D

func reset():
	self.position = Vector2.ZERO

func get_actors_at(target_position: Vector2) -> Array:
	self.global_position = target_position
	self.area.set_deferred("monitoring", true)
	
	var tree = get_tree()
	await tree.process_frame
	await tree.physics_frame
	await tree.physics_frame
	
	var hitboxes = self.area.get_overlapping_areas()
	
	return hitboxes.map(func(hitbox): return hitbox.get_parent().get_parent())

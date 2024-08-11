extends Node2D

@onready var area: Area2D = $Area2D
@onready var collision_shape = $Area2D/CollisionShape2D

func reset():
	self.position = Vector2.ZERO
	self.shape_cast.set_deferred("enabled", false)

func get_actors_in_line(from_position: Vector2, to_position: Vector2) -> Array:
	from_position = from_position + Vector2(0, -10)
	to_position = to_position + Vector2(0, -10)
	self.area.global_position = 0.5 * (from_position + to_position)
	self.collision_shape.shape.height = (from_position - to_position).length()
	self.collision_shape.rotation = PI/2.0 + (- to_position + from_position).angle()
	self.area.set_deferred("monitoring", true)
	
	var tree = get_tree()
	await tree.process_frame
	await tree.physics_frame
	await tree.physics_frame

	var hitboxes = self.area.get_overlapping_areas()
	
	var actors = []
	for hitbox in hitboxes:
		actors.append(hitbox.get_parent().get_parent())
		
	return actors

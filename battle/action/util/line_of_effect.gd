extends Node2D

@onready var shape_cast: ShapeCast2D = $ShapeCast2D

func reset():
	self.position = Vector2.ZERO
	self.shape_cast.set_deferred("enabled", false)

func get_actors_in_line(from_position: Vector2, to_position: Vector2) -> Array:
	self.global_position = from_position + Vector2(0, -10)
	self.shape_cast.target_position = to_position - from_position + Vector2(0, -5)
	self.shape_cast.set_deferred("enabled", true)
	
	
	var tree = get_tree()
	await tree.process_frame
	await tree.physics_frame
	await tree.physics_frame
	self.shape_cast.force_shapecast_update()
	
	assert(self.shape_cast.is_colliding())
	var actors = []
	for i in range(self.shape_cast.get_collision_count()):
		print("Collision!")
		var collider = self.shape_cast.get_collider(i)
		actors.append(collider.get_parent().get_parent())
		
	
	return actors

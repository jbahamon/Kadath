extends Area2D

export var room_id: String = "main_room"
export var target_position: Vector2
export (Vector2) var target_orientation: Vector2

func get_local_scene() -> Node:
	return get_node("../../../")


func _on_Stairs_body_entered(body):
	if body is PlayerProxy:
		var local_scene: LocalScene = get_local_scene()
		local_scene.call_deferred(
			"update_whereabouts", 
			local_scene.current_location.location_id, 
			self.room_id,
			target_position,
			target_orientation
		)

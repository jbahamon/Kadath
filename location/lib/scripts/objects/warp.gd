extends Area2D

export var room_id: String = "main_room"
export var target_position: Vector2
export (Vector2) var target_orientation: Vector2

func get_local_scene() -> Node:
	return get_node("../../../")

func _on_Warp_body_entered(body):
	if not body is PlayerProxy:
		return
	self.call_deferred("warp_to_destination")

func warp_to_destination():
	var local_scene: LocalScene = self.get_local_scene()
	yield(
		local_scene.update_whereabouts( 
			local_scene.current_location.location_id, 
			self.room_id,
			target_position,
			target_orientation,
			true
		), 
		"completed"
	)

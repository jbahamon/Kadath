extends Area2D

@export var room_id: String = "main_room"
@export var target_position: Vector2
@export var target_orientation: Vector2


func _on_body_entered(body):
	if not body is PlayerProxy:
		return
	self.call_deferred("warp_to_destination")

func warp_to_destination():
	await EnvironmentService.update_whereabouts( 
		EnvironmentService.current_location.location_id, 
		self.room_id,
		target_position,
		target_orientation,
		{
			"fade": true
		}
	)

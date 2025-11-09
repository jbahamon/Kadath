extends LocationRoom

func _on_to_sanctorum_body_entered(_body: Node2D) -> void:
	VarsService.set_flag("cavern_of_flame.sanctorum", true)

extends "res://battle/action/simple_single_target.gd"

@export_multiline var long_description: String

func execute(actor):
	var enemy_id = self.target.enemy_id
	VarsService.scan_enemy(enemy_id)
	self.reset()

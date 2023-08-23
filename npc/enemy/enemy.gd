extends BaseNPC

@onready var battler = $Battler

func _on_interactable_area_body_entered(body):
	BattleService.start_mook_battle()

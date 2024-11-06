extends StatusEffect

class_name DownedStatus

func _init():
	trigger = StatusEffect.Trigger.ADD | StatusEffect.Trigger.REMOVE

func get_id() -> String:
	return "downed"

func on_add(owner):
	BattleService.remove_from_queue(owner.get_parent())
	
func on_remove(owner):
	BattleService.add_to_queue(owner.get_parent())

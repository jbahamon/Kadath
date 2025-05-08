extends InventoryItem

class_name Equipment

@export_flags ("Alex", "Volki", "Gruska", "Sylvie", "Pickman", "Kuranes", "Zkauba", "Carter") var equippable_by

@export var health_bonus: int = 0
@export var energy_bonus: int = 0
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var magic_attack_bonus: int = 0
@export var magic_defense_bonus: int = 0
@export var speed_bonus: int = 0

var bonuses_str: String:
	get:
		var bonus_str = ""
		
		if health_bonus > 0:
			bonus_str += "+%d HP, " % health_bonus
		
		if energy_bonus > 0:
			bonus_str += "+%d SP, " % energy_bonus
			
		if attack_bonus > 0:
			bonus_str += "+%d Atk, " % attack_bonus
		
		if defense_bonus > 0:
			bonus_str += "+%d Def, " % defense_bonus
			
		if magic_attack_bonus > 0:
			bonus_str += "+%d M. Atk, " % magic_attack_bonus
			
		if magic_defense_bonus > 0:
			bonus_str += "+%d M. Def, " % magic_defense_bonus
			
		if speed_bonus > 0:
			bonus_str += "+%d Spd, " % speed_bonus
			
		return bonus_str.trim_suffix(", ")

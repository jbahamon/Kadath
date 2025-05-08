extends BaseNPC

class_name Enemy

signal touched(body)

@export var battle_on_contact = true
@export var enemy_id: String
@export var icon: Texture2D
@export var height: int = 0
@export_multiline var enemy_info: String
@onready var battler: Battler = $Battler


var instance_id = ""

var in_battle_id: String:
	get:
		return "%s_%s" % [self.enemy_id, instance_id]

var max_health:
	get:
		return self.battler.stats.max_health

var health: int:
	get:
		return self.battler.health
		
var energy: int:
	get:
		return self.battler.energy

var is_alive: bool: 
	get:
		return self.battler.is_alive

func _ready() -> void:
	super._ready()
	self.battler.reset_stats()
	
func get_display_name():
	return self.base_display_name if self.instance_id == "" else "%s %s" % [self.base_display_name, self.instance_id]
	
func _on_interactable_area_body_entered(body):
	self.touched.emit(body)
	if battle_on_contact:
		BattleService.start_mook_battle({
			"escapable": true
		})

func show_toast(text: String, color: Color=Color.WHITE):
	return self.battler.show_toast(text, color)
	
# Battle methods

func heal(amount: int, in_battle: bool = true):
	return self.battler.heal(amount, in_battle)
	
func recover_energy(amount: int, in_battle: bool = true):
	return self.battler.recover_energy(amount, in_battle)
	
func take_hit(actor, hit: Hit):
	return await self.battler.take_hit(actor, hit)
	
func get_allies(actors: Array):
	if self.battler.status_effects.targeting_changed:
		return self.battler.status_effects.get_allies(actors)
	return actors.filter(func(actor): return not actor is PartyMember)
	
func get_enemies(actors: Array):
	if self.battler.status_effects.targeting_changed:
		return self.battler.status_effects.get_enemies(actors)
	return actors.filter(func(actor): return actor is PartyMember)

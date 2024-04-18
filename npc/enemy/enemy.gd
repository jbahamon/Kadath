extends BaseNPC

signal touched(body)

@export var battle_on_contact = true
@onready var battler: Battler = $Battler

var health:
	get:
		return self.battler.stats.health
		
var energy:
	get:
		return self.battler.stats.energy
		
func _on_interactable_area_body_entered(body):
	self.touched.emit(body)
	if battle_on_contact:
		BattleService.start_mook_battle(true)

func show_toast(text: String, color: Color=Color.WHITE):
	await self.battler.show_toast(text, color)
	
# Battle methods

func heal(amount: int):
	self.battler.heal(amount)
	
func recover_energy(amount: int):
	self.battler.recover_energy(amount)
	
func take_hit(hit: Hit):
	await self.battler.take_hit(hit)
	
func get_allies(actors: Array):
	var allies = []
	for actor in actors:
		if not actor is PartyMember:
			allies.append(actor)
	return allies
	
func get_enemies(actors: Array):
	var enemies = []
	for actor in actors:
		if actor is PartyMember:
			enemies.append(actor)
	return enemies

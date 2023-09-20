extends BaseNPC

@onready var battler = $Battler

func _on_interactable_area_body_entered(body):
	BattleService.start_mook_battle(true)


# Battle methods

func take_hit(hit: Hit):
	self.battler.take_damage(hit)
	
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

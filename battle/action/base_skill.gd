extends BattleAction

@export var cost: int
@export var unlocked = true
var is_player_skill: bool
var battler

func _ready():
	# only player skills are nested
	self.is_player_skill = get_parent() is CompositeBattleOption
	
	self.battler = (
		self.get_parent().get_parent().get_parent() if self.is_player_skill else
		self.get_parent().get_parent()
	)
func is_disabled():
	return self.is_player_skill and self.battler.stats.energy < self.cost
	
func unlock():
	self.unlocked = true

extends "res://battle/ai/non_player_ai.gd"

var Change = preload("res://npc/enemy/thymiaterion/reaction/change.gd")

@onready var jump = self.get_node("../Actions/Jump")
@onready var shoot = self.get_node("../Actions/Shoot")
@onready var whip = self.get_node("../Actions/Whip")
@onready var prepare = self.get_node("../Actions/PrepareChew")
@onready var chew = self.get_node("../Actions/Chew")
@onready var counter = self.get_node("../Actions/Counter")
@export var change_material: Material

var turn_counter = 0
var second_phase = false

func _ready() -> void:
	self.reactions = [Change.new(self.change_material)]

func choose_action(_actor, _actors: Array):
	if not second_phase:
		match turn_counter:
			0:
				turn_counter += 1
				return self.chew
			1: 
				turn_counter += 1
				return self.shoot
			_:
				turn_counter = 0
				return self.jump
	else:
		if counter.counter_reaction in self.reactions:
			await BattleService.announce("Counterattack failed.", UIService.PROMPT_WAIT_TIME)
			self.remove_reaction(counter.counter_reaction)
			
		match turn_counter:
			0, 1:
				turn_counter += 1
				return self.whip
			2:
				turn_counter += 1
				return self.counter
			3: 
				turn_counter += 1
				return self.whip
			4:
				turn_counter += 1
				return self.prepare
			5:
				turn_counter = 0
				return self.chew

func fill_action_parameters(action: BattleAction, actor, actors: Array):
	if action == self.jump or action == self.chew:
		action.targets = TargetUtil.all_enemies(actor, actors)
	elif action == self.shoot or action == self.whip:
		action.target = TargetUtil.one_enemy(actor, actors).pick_random()

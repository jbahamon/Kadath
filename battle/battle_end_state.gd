enum Result {
	UNSET,
	WIN,
	LOSE,
	ESCAPE,
}

var result: Result
var party_actors: Array
var enemy_actors: Array
var rewards: BattleRewards

func _init():
	party_actors = []
	enemy_actors = []
	rewards = BattleRewards.new()
	rewards.clear()
	
func add_rewards(new_rewards: BattleRewards):
	self.rewards.add_from(new_rewards)

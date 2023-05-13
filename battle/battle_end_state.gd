var player_won: bool
var rewards: BattleRewards

func _init():
	rewards = BattleRewards.new()
	rewards.clear()
	
func add_rewards(new_rewards: BattleRewards):
	self.rewards.add_from(new_rewards)

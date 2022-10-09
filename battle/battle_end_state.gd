var player_won: bool
var rewards: BattleRewards

func _init():
	rewards = BattleRewards.new()
	rewards.clear()
	
func add_rewards(rewards: BattleRewards):
	self.rewards.add_from(rewards)

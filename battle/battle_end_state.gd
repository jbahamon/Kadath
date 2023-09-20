var player_won: bool
var party_actors: Array
var rewards: BattleRewards

func _init():
	party_actors = []
	rewards = BattleRewards.new()
	rewards.clear()
	
func add_rewards(new_rewards: BattleRewards):
	self.rewards.add_from(new_rewards)

func set_active_party_actors(actors: Array):
	self.party_actors = actors

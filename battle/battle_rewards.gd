extends Resource

class_name BattleRewards

@export var item_amounts: Dictionary
@export var experience: int
@export var money: int


var items : get = get_items

func get_items():
	var returned_items = {}
	
	for item in item_amounts:
		var amount = floor(item_amounts[item])
		
		var additional_probability = item_amounts[item] - amount
		if additional_probability > 0 and randf() < additional_probability:
			amount += 1
		
		returned_items[item] = amount
		
	return returned_items
	
func add_from(rewards: BattleRewards):
	for item in rewards.item_amounts:
		var total = self.item_amounts.get(item, 0) + rewards.item_amounts[item]
		self.item_amounts[item] = total
	self.experience += rewards.experience
	self.money += rewards.money

func clear():
	item_amounts = {}
	experience = 0
	money = 0

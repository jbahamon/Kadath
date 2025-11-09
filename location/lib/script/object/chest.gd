extends "res://location/lib/script/object/simple_interactable_object.gd"


@export var flag_name: String
@export var is_money: bool = false
@export var item_id: String = ""
@export var amount: int = 1

func _ready() -> void:
	if VarsService.get_flag(self.flag_nme):
		self.turn_off()
	

func on_player_interaction(proxy: PlayerProxy):
	super.on_player_interaction(proxy)
	var str 
	if self.is_money:
		str = "%s G" % amount
		EntitiesService.party.inventory.add_money(amount)
	else:
		EntitiesService.party.inventory.add(item_id, amount)
		var item = ItemService.id_to_item(self.item_id)
		str = "%s x %s" % [item.display_name, self.amount] if self.amount > 1 else item.display_name
	await DialogueService.open_global_dialogue("chest", DialogueService.Alignment.BOTTOM, str)
		
	VarsService.set_flag(self.flag_name, true)
	
	await DialogueService.open_global_dialogue("chest")
	self.turn_off()
	
func turn_off():
	# Remove from layer 3, interactables
	self.collision_layer &= ~(1 << 3)

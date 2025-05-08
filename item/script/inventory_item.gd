extends Resource

class_name InventoryItem

enum TargetType {
	ALL_ALLIES,
	ALL_ENEMIES,
	SINGLE,
	
	NONE
}
@export var id: String 
@export var display_name: String
@export_multiline var description: String
@export var max_amount: int = 99
@export var category: ItemService.ItemCategory
@export var target_type: BattleAction.TargetType = BattleAction.TargetType.NONE

@export var usable_in_menu: bool = false
@export var usable_in_battle: bool = false
@export var consumed_after_use: bool = true

func needs_targets():
	return self.target_type != BattleAction.TargetType.NONE
	
func is_multi_target():
	return self.target_type == BattleAction.TargetType.ALL_ALLIES or \
		self.target_type == BattleAction.TargetType.ALL_ENEMIES

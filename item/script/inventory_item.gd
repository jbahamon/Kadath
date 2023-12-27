extends Resource

class_name InventoryItem

@export var id: String 
@export var name: String
@export var description: String
@export var max_amount: int = 99
@export var category: ItemService.ItemCategory
@export var target_type: BattleAction.TargetType = BattleAction.TargetType.NONE

@export var usable_in_menu: bool = false
@export var usable_in_battle: bool = false
@export var consumed_after_use: bool = true

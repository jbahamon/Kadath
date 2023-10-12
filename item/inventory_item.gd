extends Resource

class_name InventoryItem

@export var id: String 
@export var name: String
@export var description: String
@export var max_amount: int = 99
@export var category: ItemService.ItemCategory

var usable_outside_of_battle: bool = false
var usable_in_battle: bool = false
var tossable: bool = true


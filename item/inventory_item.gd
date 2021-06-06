extends Resource

class_name InventoryItem

export var name: String
export(String, MULTILINE) var description: String
export var max_amount: int = 99

export var usable_outside_of_battle: bool = false
export var usable_in_battle: bool = false
export var tossable: bool = true

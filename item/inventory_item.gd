extends Resource

enum ItemCategory {CONSUMABLE, WEAPON, ARMOR, ACCESSORY, QUEST, OTHER}

class_name InventoryItem

export var name: String
export(String, MULTILINE) var description: String
export(ItemCategory) var category: int
export var max_amount: int = 99

export var usable_outside_of_battle: bool = false
export var usable_in_battle: bool = false

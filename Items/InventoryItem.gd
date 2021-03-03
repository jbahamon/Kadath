enum ItemCategory {CONSUMABLE, WEAPON, ARMOR, ACCESSORY, QUEST, OTHER}

class_name InventoryItem

var item_id: String
var name: String
var description: String
var category: int

var amount: int
var max_amount: int

var usable_outside_of_battle = false
var usable_in_battle = false


func _init(new_item_id, definition, n=1):
	self.item_id = new_item_id
	self.name = definition["name"]
	self.description = definition["description"]
	self.max_amount = int(definition["max_amount"])
	self.amount = int(clamp(n, 0, self.max_amount))
	self.category = category_from_string(definition["category"])


func add(n: int):
	self.amount = int(clamp(self.amount + n, 0, self.max_amount))
	
	
func remove(n: int):
	self.amount = int(clamp(self.amount - n, 0, self.max_amount))


static func category_from_string(string: String):
	match string:
		"armor": return ItemCategory.ARMOR
		"weapon": return ItemCategory.WEAPON
		"accessory": return ItemCategory.ACCESSORY
		"consumable": return ItemCategory.CONSUMABLE
		"quest": return ItemCategory.QUEST
		"other": return ItemCategory.OTHER
		_: push_error("Unsupported item category %s" % string)

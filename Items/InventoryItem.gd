enum ItemCategory {CONSUMABLE, QUEST, EQUIPMENT, OTHER}

class_name InventoryItem

var item_id: String
var name: String
var description: String
var category: int

var amount: int
var max_amount: int


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
		"equipment": return ItemCategory.EQUIPMENT
		"consumable": return ItemCategory.CONSUMABLE
		"quest": return ItemCategory.QUEST
		"other": return ItemCategory.OTHER
		_: push_error("Unsupported item category %s" % string)

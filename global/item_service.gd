extends Node

enum ItemCategory {
	CONSUMABLE,
	EQUIPMENT,
	KEY
}


var item_definitions: Dictionary # id (string) -> InventoryItem

func _init():
	# TODO: 
	var salts = InventoryItem.new()
	salts.id = "salts"
	salts.name = "Essential Salts"
	salts.description = "Revives a fallen ally."
	salts.category = ItemCategory.CONSUMABLE
	salts.max_amount = 99
	self.item_definitions = {
		"salts": salts
	}
	
func id_to_item(id: String) -> InventoryItem:
	return self.item_definitions.get(id)
	
func item_to_id(item: InventoryItem) -> String:
	return item.id

func category_name(category: ItemCategory) -> String:
	match category:
		ItemCategory.EQUIPMENT:
			return "Equipment"
		ItemCategory.CONSUMABLE:
			return "Consumables"
		ItemCategory.KEY:
			return "Important Items"
		null:
			return "All Items"
			
	return "Other"
	
class ItemSorter:
	static func sort_ascending(a: InventoryItem, b: InventoryItem):
		if a.category != b.category:
			return a.get_class() < b.get_class()
		else:
			return a.name < b.name

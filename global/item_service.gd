extends Node

enum ItemCategory {
	CONSUMABLE,
	EQUIPMENT,
	KEY
}

var item_definitions: Dictionary

func _init():
	self.item_definitions = {}
	for folder in ["consumable", "equipment", "key"]:
		for file_name in self.get_all_files("res://item/resource/%s/" % folder, "tres"):
			var item_resource = load(file_name)
			self.item_definitions[item_resource.id] = item_resource
	
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

func get_all_files(path: String, file_ext := "tres", files := []):
	var dirs = ResourceLoader.list_directory(path)
	
	for file_name in dirs:
		var extension = file_name.get_extension() 
		match extension:
			"":
				files = get_all_files(path.path_join(file_name), file_ext, files)
			file_ext:
				files.append(path.path_join(file_name))

	return files

class ItemSorter:
	static func sort_ascending(a: InventoryItem, b: InventoryItem):
		if a.category != b.category:
			return a.category < b.category
		else:
			return a.id < b.id

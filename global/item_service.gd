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
			var item_resource: InventoryItem = load(file_name)
			self.item_definitions[item_resource.id] = item_resource
	print(self.item_definitions)
	
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

func get_all_files(path: String, file_ext := "", files := []):
	var dir = DirAccess.open(path)

	if dir:
		dir.list_dir_begin()

		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				files = get_all_files(dir.get_current_dir().path_join(file_name), file_ext, files)
			else:
				if file_ext and file_name.get_extension() != file_ext:
					file_name = dir.get_next()
					continue

				files.append(dir.get_current_dir().path_join(file_name))

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access %s." % path)

	return files

class ItemSorter:
	static func sort_ascending(a: InventoryItem, b: InventoryItem):
		if a.category != b.category:
			return a.get_class() < b.get_class()
		else:
			return a.name < b.name

class_name Inventory

var ItemFactory = preload("res://Items/ItemFactory.gd")
var item_factory = ItemFactory.new()
var current_items: Array = []

var factory = ItemFactory.new()

func load_save_data(save_data):
	var items_dict = {}
	for item in save_data.inventory:
		var item_id = item[0]
		var n = item[1]
		var item_definition = Constants.items[item_id]
		items_dict[item_id] = factory.build_from_definition(
				item_id, 
				item_definition, 
				n
		)
	current_items = items_dict.values()
	

func add_item(item_id, n=1):
	for item in current_items:
		if item.item_id == item_id:
			item.add(n)
			return
	
	var item_definition = Constants.items[item_id]
	current_items.push_back(factory.build_from_definition(
			item_id, 
			item_definition, 
			n
	))
		
	
func remove_item(item_id, n=1):
	for i in len(current_items):
		var item = current_items[i]
		if item.item_id == item_id:
			item.remove(n)
			if item.amount <= 0:
				current_items.remove(i)
			return

func swap_items(i1, i2):
	var temp_item = current_items[i1]
	current_items[i1] = current_items[i2]
	current_items[i2] = temp_item

func has(item_id):
	for item in current_items:
		if item.item_id == item_id:
			return true
			
	return false


func get_ids_and_amounts():
	var ids_and_amounts = []
	
	for item in current_items:
		ids_and_amounts.push_back([item.item_id, item.amount])
		
	return ids_and_amounts
	

func sort():
	current_items.sort_custom(ItemSorter, "sort_ascending")
	
class ItemSorter:
	static func sort_ascending(a: InventoryItem, b: InventoryItem):
		if a.category != b.category:
			return a.category < b.category
		else:
			return a.name < b.name

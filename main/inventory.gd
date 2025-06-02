extends RefCounted
class_name Inventory

signal inventory_changed(change_type)

enum Change {
	ADD,
	SET,
	REMOVE,
	SORT,
	SWAP
}

const save_key = "inventory"
var amounts = {}
var order = []

@export var MAX_COINS = 9999999

func load_game_data(save_data: SaveData) -> void:
	self.amounts = save_data.data[save_key]["amounts"]
	self.order = save_data.data[save_key]["order"]

func save(save_data: SaveData) -> void:
	save_data.data[save_key] = {
		"amounts": self.amounts,
		"order": self.order
	}

func add(item_id: String, amount: int = 1) -> void:
	
	var max_amount = ItemService.id_to_item(item_id).max_amount
	if item_id in amounts:
		amounts[item_id] = min(amounts[item_id] + amount, max_amount)
	else:
		amounts[item_id] = min(amount, max_amount)
		order.push_back(item_id)
	
	self.inventory_changed.emit(Change.ADD)

func set_item(item_id: String, amount: int) -> void:
	var max_amount = ItemService.id_to_item(item_id).max_amount
	if item_id not in amounts:
		order.push_back(item_id)
	amounts[item_id] = min(amount, max_amount)
	
	self.inventory_changed.emit(Change.SET)		
	
func remove(item: String, amount: int = 1) -> void:
	assert(item in amounts)
	assert(amount <= amounts[item])
	assert(item in order)
	
	amounts[item] -= amount
		
	if amounts[item] <= 0:
		amounts.erase(item)
		order.erase(item)

	self.inventory_changed.emit(Change.REMOVE)
	
func swap_items(i1: int, i2: int) -> void:
	var temp_item: InventoryItem = order[i1]
	order[i1] = order[i2]
	order[i2] = temp_item
	self.inventory_changed.emit(Change.SWAP)

func has(item_id: String):
	return item_id in amounts

func get_sorted_items_amounts(category = null) -> Array:
	var ids_and_amounts = []
	
	for item in order:
		if category == null or ItemService.id_to_item(item).category == category:
			ids_and_amounts.push_back([item, amounts[item]])
		
	return ids_and_amounts
	
func get_batle_items_amounts() -> Array:
	var ids_and_amounts = []
	
	for item in order:
		if ItemService.id_to_item(item).usable_in_battle:
			ids_and_amounts.push_back([item, amounts[item]])
		
	return ids_and_amounts
	
func get_equipment(cls, equippable_flag: int) -> Array:
	return order.filter(
		func(item_id):
			var item = ItemService.id_to_item(item_id)
			return cls.instance_has(item) and (item.equippable_by & equippable_flag)
	).map(func (item_id): return ItemService.id_to_item(item_id))

func sort():
	var items = order.map(func(item_id): return ItemService.get_item(item_id))
	items.sort_custom(Callable(ItemService.ItemSorter,"sort_ascending"))
	
	self.order = items.map(func(item): return item.id)
	self.inventory_changed.emit(Change.SORT)

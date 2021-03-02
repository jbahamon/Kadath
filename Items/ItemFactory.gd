var item_classes = {
	"InventoryItem": InventoryItem
}

func build_from_definition(id, definition, n):
	var item_class = get_item_class(definition)
	return item_class.new(id, definition, n)

func get_item_class(definition):
	var item_class_name = definition.get("class", "InventoryItem")
	
	if not item_classes.has(item_class_name):
		item_classes[item_class_name] = load("res://Items/%s.gd" % item_class_name)
	
	return item_classes[item_class_name]


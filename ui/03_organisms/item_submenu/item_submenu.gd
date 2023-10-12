extends PanelContainer

var ItemEntry = preload("res://ui/02_molecules/item_entry/item_entry.tscn")
var PartyMemberListItem = preload("res://ui/02_molecules/party_member_list_item/party_member_list_item.tscn")

@export var icon: Texture2D 

@onready var first_category: Button = $HBoxContainer/GridContainer/Categories.get_children()[0]

@onready var consumables_button: Button = $HBoxContainer/GridContainer/Categories/Consumables
@onready var equipment_button: Button = $HBoxContainer/GridContainer/Categories/Equipment
@onready var key_items_button: Button = $HBoxContainer/GridContainer/Categories/KeyItems

@onready var category_name: Label = $HBoxContainer/GridContainer/CategoryName
@onready var items = $HBoxContainer/GridContainer/ItemsAndActions/Items

var inventory: Inventory

var categories_button_group = ButtonGroup.new()

func _ready():
	consumables_button.button_group = categories_button_group
	equipment_button.button_group = categories_button_group
	key_items_button.button_group = categories_button_group
	
func initialize(party: Party):
	
	self.inventory = party.inventory
	var party_members = party.get_unlocked_characters()
	$HBoxContainer/PartyList.initialize(party_members, PartyMemberListItem)
	
func on_grab_focus():
	first_category.button_pressed = true
	first_category.grab_click_focus()
	first_category.grab_focus()
	

func focus_category(category: ItemService.ItemCategory):
	category_name.text = ItemService.category_name(category)
	inventory.set_item("salts", 1)
	
	items.initialize(inventory.get_sorted_items_amounts(category), ItemEntry)


func _on_consumables_pressed():
	print("consumables")


func _on_consumables_focus_entered():
	self.consumables_button.button_pressed = true
	self.focus_category(ItemService.ItemCategory.CONSUMABLE)


func _on_equipment_pressed():
	print("equipment")
	
func _on_equipment_focus_entered():
	self.equipment_button.button_pressed = true
	self.focus_category(ItemService.ItemCategory.EQUIPMENT)


func _on_key_items_pressed():
	print("key")
	
func _on_key_items_focus_entered():
	self.key_items_button.button_pressed = true
	self.focus_category(ItemService.ItemCategory.KEY)


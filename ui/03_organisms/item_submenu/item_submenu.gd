extends PanelContainer

signal exit_submenu

var ItemEntry = preload("res://ui/02_molecules/item_entry/item_entry.tscn")
var PartyMemberListItem = preload("res://ui/02_molecules/party_member_list_item/party_member_list_item.tscn")

@export var icon: Texture2D 

@onready var categories: Container = $HBoxContainer/Categories
@onready var first_category: Button = $HBoxContainer/Categories.get_children()[0]

@onready var consumables_button: Button = $HBoxContainer/Categories/Consumables
@onready var equipment_button: Button = $HBoxContainer/Categories/Equipment
@onready var key_items_button: Button = $HBoxContainer/Categories/KeyItems

@onready var items = $HBoxContainer/ItemsAndActions/Items
@onready var description: Label = $HBoxContainer/ItemsAndActions/Description
@onready var actions: HBoxContainer = $HBoxContainer/ItemsAndActions/Actions

var inventory: Inventory

var categories_button_group = ButtonGroup.new()

func _ready():
	consumables_button.button_group = categories_button_group
	equipment_button.button_group = categories_button_group
	key_items_button.button_group = categories_button_group
	
func initialize():
	var party = EntitiesService.get_party()
	self.inventory = party.inventory
	inventory.set_item("salts", 1)
	var party_members = party.get_unlocked_characters()
	$HBoxContainer/PartyList.initialize(party_members, PartyMemberListItem)
	reset_controls()
	
func reset_controls():
	items.initialize([], ItemEntry)
	description.text = ''
	description.visible = true
	actions.visible = false
	var pressed = categories_button_group.get_pressed_button()
	if pressed != null:
		pressed.button_pressed = false
	
func on_grab_focus():
	first_category.button_pressed = true
	first_category.grab_click_focus()
	first_category.grab_focus()

func _on_consumables_focus_entered():
	self.consumables_button.button_pressed = true
	self._on_category_focused(ItemService.ItemCategory.CONSUMABLE)
	
func _on_equipment_focus_entered():
	self.equipment_button.button_pressed = true
	self._on_category_focused(ItemService.ItemCategory.EQUIPMENT)
	
func _on_key_items_focus_entered():
	self.key_items_button.button_pressed = true
	self._on_category_focused(ItemService.ItemCategory.KEY)

func _on_category_focused(category: ItemService.ItemCategory):
	items.initialize(inventory.get_sorted_items_amounts(category), ItemEntry)

func _on_category_pressed():
	if items.get_children().size() > 0:
		items.on_grab_focus()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and self.is_focus_on_categories():
		emit_signal("exit_submenu")
		get_viewport().set_input_as_handled()

func is_focus_on_categories():
	for child in categories.get_children():
		if child.has_focus():
			return true
	return false
	
func _on_items_element_focused(item_and_amount: Array):
	description.text = ItemService.id_to_item(item_and_amount[0]).description

func _on_items_cancel():
	reset_controls()
	var button = categories_button_group.get_pressed_button()
	if button == null:
		button = first_category
	
	button.grab_click_focus()
	button.grab_focus()
	

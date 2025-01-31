extends PanelContainer

signal exit_submenu

const select_controls = "[ {ui_up} ]/[ {ui_down} ] : Select  [ {ui_cancel} ]: Return  [ {ui_accept} ]: Confirm"

var ItemEntry = preload("res://ui/02_molecules/item_entry/item_entry.tscn")
var PartyMemberListItem = preload("res://ui/02_molecules/party_member_list_item/party_member_list_item.tscn")

@export var icon: Texture2D 
@export var help_text: String
@export var controls_text: String

@onready var categories: Container = $VBoxContainer/HBoxContainer/Categories
@onready var first_category: Button = $VBoxContainer/HBoxContainer/Categories.get_children()[0]

@onready var consumables_button: Button = $VBoxContainer/HBoxContainer/Categories/Consumables
@onready var equipment_button: Button = $VBoxContainer/HBoxContainer/Categories/Equipment
@onready var key_items_button: Button = $VBoxContainer/HBoxContainer/Categories/KeyItems

@onready var items = $VBoxContainer/HBoxContainer/Items
@onready var party_list = $VBoxContainer/HBoxContainer/PartyList

var inventory: Inventory
var current_category = null
var categories_button_group = ButtonGroup.new()
var selected_item

func _ready():
	self.consumables_button.button_group = self.categories_button_group
	self.equipment_button.button_group = self.categories_button_group
	self.key_items_button.button_group = self.categories_button_group
	
func initialize():
	var party = EntitiesService.party
	var party_members = party.get_unlocked_characters()
	self.party_list.initialize(party_members, {"class_or_scene": PartyMemberListItem})
	
	self.inventory = party.inventory
	self.reset_controls()
	
func reset_controls(reset_categories = true):
	var pressed = categories_button_group.get_pressed_button()
	if reset_categories and pressed != null:
		pressed.button_pressed = false
		self.current_category = null
	
	self.update_shown_items()
	
	
func on_grab_focus():
	self.first_category.button_pressed = true
	self.first_category.grab_click_focus()
	self.first_category.grab_focus()

func update_shown_items():
	self.items.initialize(
		inventory.get_sorted_items_amounts(self.current_category), 
		{
			"class_or_scene": ItemEntry, 
			"disable_func": (
				func (item_and_amount):
					var disabled = not ItemService.id_to_item(item_and_amount[0]).usable_in_menu
					return disabled
					)
		}
	)
	
func _on_consumables_focus_entered():
	UIService.set_menu_help("Consumable items, including recovery items.", select_controls)
	self.consumables_button.button_pressed = true
	self._on_category_focused(ItemService.ItemCategory.CONSUMABLE)
	
func _on_equipment_focus_entered():
	UIService.set_menu_help("Weapons, armor and accessories.", select_controls)
	self.equipment_button.button_pressed = true
	self._on_category_focused(ItemService.ItemCategory.EQUIPMENT)
	
func _on_key_items_focus_entered():
	UIService.set_menu_help("Important and unique items.", select_controls)
	self.key_items_button.button_pressed = true
	self._on_category_focused(ItemService.ItemCategory.KEY)

func _on_category_focused(category: ItemService.ItemCategory):
	self.current_category = category
	self.update_shown_items()

func _on_category_pressed():
	if self.items.size() > 0:
		self.items.on_grab_focus()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and self.is_focus_on_categories():
		self.exit_submenu.emit()
		self.get_viewport().set_input_as_handled()

func is_focus_on_categories():
	return self.categories_button_group.get_buttons().any(func(button): return button.has_focus())

func _on_items_element_focused(ui_element):
	var item = ItemService.id_to_item(ui_element.item_id)
	UIService.set_menu_help(item.description, select_controls)

func _on_items_element_selected(ui_element):
	self.selected_item = ui_element
	var item: InventoryItem = ItemService.id_to_item(self.selected_item.item_id)
	if not item.usable_in_menu:
		return
	assert('use' in item)
	# set party select mode depending on item
	self.party_list.on_grab_focus()

func _on_items_cancel():
	self.reset_controls(false)
	var button = categories_button_group.get_pressed_button()
	if button == null:
		button = self.first_category
	
	button.grab_click_focus()
	button.grab_focus()

func _on_party_list_element_selected(element):
	self.party_list.element_selected.disconnect(self._on_party_list_element_selected)
	var item: InventoryItem = ItemService.id_to_item(self.selected_item.item_id)
	var used = await item.use([element])
	self.party_list.deselect()
	if used and item.consumed_after_use:
		self.inventory.remove(item.id, 1)
		if self.inventory.has(item.id):
			self.selected_item.amount = self.inventory.amounts[item.id]
			self.selected_item.update_item()
		else:
			self.update_shown_items()
			self._on_party_list_cancel()
	self.party_list.element_selected.connect(self._on_party_list_element_selected)

func _on_party_list_cancel():
	self.selected_item = null
	if self.items.size() > 0:
		self.items.on_grab_focus()
	else:
		self._on_items_cancel()

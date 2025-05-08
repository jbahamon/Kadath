extends PanelContainer

signal item_requested(cls, party_member)
signal focus_released

@onready var sprite: TextureRect = $VBoxContainer/SummaryContainer/CenterContainer/Sprite
@onready var level: Label = $VBoxContainer/SummaryContainer/VBoxContainer/Level
@onready var next_level: Label = $VBoxContainer/SummaryContainer/VBoxContainer/NextLevel

@onready var weapon_name: Button = $VBoxContainer/EquipmentContainer/Equipment/WeaponName
@onready var weapon_stats: Label = $VBoxContainer/EquipmentContainer/Equipment/WeaponStats
@onready var armor_name: Button = $VBoxContainer/EquipmentContainer/Equipment/ArmorName
@onready var armor_stats: Label = $VBoxContainer/EquipmentContainer/Equipment/ArmorStats
@onready var accessory_name: Button = $VBoxContainer/EquipmentContainer/Equipment/AccessoryName
@onready var accessory_stats: Label = $VBoxContainer/EquipmentContainer/Equipment/AccessoryStats

@onready var health_value: Label = $VBoxContainer/SummaryContainer/Stats/HPValue
@onready var energy_value: Label = $VBoxContainer/SummaryContainer/Stats/EPValue
@onready var attack_value: Label = $VBoxContainer/SummaryContainer/Stats/AttackValue
@onready var defense_value: Label = $VBoxContainer/SummaryContainer/Stats/DefenseValue
@onready var magic_attack_value: Label = $VBoxContainer/SummaryContainer/Stats/MagicAttackValue
@onready var magic_defense_value: Label = $VBoxContainer/SummaryContainer/Stats/MagicDefenseValue
@onready var speed_value: Label = $VBoxContainer/SummaryContainer/Stats/SpeedValue

@onready var unique_command_label: Label = $VBoxContainer/UniqueCommandTitle/UniqueCommandLabel
@onready var unique_command_description: RichTextLabel = $VBoxContainer/UniqueCommandDescription

var party_member

var selected_property: String = ""
var selected_button: Button = null

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and self.element_has_focus():
		self.set_process_unhandled_input(false)
		self.focus_released.emit()
		self.get_viewport().set_input_as_handled()
		
func on_party_member_focused(focused_party_member):
	if focused_party_member != null:
		self.party_member = focused_party_member
		update_ui_info()

func on_party_member_selected(selected_party_member):
	if selected_party_member != null:
		on_party_member_focused(selected_party_member)
		self.set_process_unhandled_input(true)
		self.on_grab_focus()
	
func update_ui_info():
	set_text(weapon_name, party_member.equipped_weapon, "display_name", "--")
	set_text(weapon_stats, party_member.equipped_weapon, "bonuses_str", "")
	set_text(armor_name, party_member.equipped_armor, "display_name", "--")
	set_text(armor_stats, party_member.equipped_armor, "bonuses_str", "")
	set_text(accessory_name, party_member.equipped_accessory, "display_name", "--")
	set_text(accessory_stats, party_member.equipped_accessory, "bonuses_str", "")
	
	sprite.texture = party_member.menu_texture
	sprite.custom_minimum_size = sprite.texture.get_size() * 3
	var battler: Battler = party_member.battler
	level.text = "Lv. %d" % battler.stats.level
	var exp_for_next_level = party_member.growth.get_experience_for_level_up(battler.stats.level, party_member.experience)
	
	var next_level_str = ("%s XP" % exp_for_next_level if exp_for_next_level > 0 else "--")
	next_level.text = "To next level: %s" % next_level_str
	
	health_value.text = str(int(battler.stats.max_health))
	energy_value.text = str(int(battler.stats.max_energy))
	attack_value.text = str(int(battler.attack))
	defense_value.text = str(int(battler.defense))
	magic_attack_value.text = str(int(battler.magic_attack))
	magic_defense_value.text = str(int(battler.magic_defense))
	speed_value.text = str(int(battler.speed))
	
	var unique_command = party_member.get_node(party_member.unique_command)
	unique_command_label.text = "Special Command: %s" % unique_command.display_name
	unique_command_description.text = unique_command.long_description
	

func element_has_focus() -> bool:
	return (weapon_name.has_focus() or 
	armor_name.has_focus() or accessory_name.has_focus())
	
func set_text(control: Control, item: Equipment, attribute: String, default: String):
	if item != null and item.get(attribute) != null:
		control.text = str(item.get(attribute))
	else:
		control.text = default
		
func on_weapon_clicked():
	selected_property = "equipped_weapon"
	selected_button = weapon_name
	self.item_requested.emit(
		Weapon, 
		party_member
	)
	

func on_armor_clicked():
	selected_property = "equipped_armor"
	selected_button = armor_name
	self.item_requested.emit(
		Armor, 
		party_member
	)
	
	
func on_accessory_clicked():
	selected_property = "equipped_accessory"
	selected_button = accessory_name
	self.item_requested.emit(
		Accessory, 
		party_member
	)
	
	
func on_item_selected(item):
	assert(selected_property != null)
	assert(party_member != null)
	var party: Party = EntitiesService.party
	var equipped_item = party_member.get(selected_property)
	if equipped_item != null:
		party.inventory.add(equipped_item.id)
	if item != null:
		party.inventory.remove(item.id)
		
	party_member.set(selected_property, item)
	party_member.on_equipment_updated()
	update_ui_info()
		
func on_grab_focus():
	UIService.set_menu_help(
		"Choose the equipment to change.",
		"[{ui_up}]/[{ui_down}]: Select [{ui_cancel}]: Return [{ui_accept}]: Confirm"
	)

	if selected_button != null:
		selected_button.button_pressed = false
		selected_button.grab_click_focus()
		selected_button.grab_focus()
		selected_button = null
	else:
		weapon_name.grab_click_focus()
		weapon_name.grab_focus()

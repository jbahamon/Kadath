extends PanelContainer

signal item_requested(cls, party_member)
signal focus_released

@onready var weapon_name: Button = $HBoxContainer/Panel/MarginContainer/Equipment/WeaponName
@onready var weapon_stats: Label = $HBoxContainer/Panel/MarginContainer/Equipment/WeaponStats
@onready var helmet_name: Button = $HBoxContainer/Panel/MarginContainer/Equipment/HelmetName
@onready var helmet_stats: Label = $HBoxContainer/Panel/MarginContainer/Equipment/HelmetStats
@onready var armor_name: Button = $HBoxContainer/Panel/MarginContainer/Equipment/ArmorName
@onready var armor_stats: Label = $HBoxContainer/Panel/MarginContainer/Equipment/ArmorStats
@onready var accessory_name: Button = $HBoxContainer/Panel/MarginContainer/Equipment/AccessoryName

@onready var attack_value: Label = $HBoxContainer/Panel/Stats/AttackValue
@onready var defense_value: Label = $HBoxContainer/Panel/Stats/DefenseValue
@onready var magic_attack_value: Label = $HBoxContainer/Panel/Stats/MagicAttackValue
@onready var magic_defense_value: Label = $HBoxContainer/Panel/Stats/MagicDefenseValue
@onready var speed_value: Label = $HBoxContainer/Panel/Stats/SpeedValue
@onready var luck_value: Label = $HBoxContainer/Panel/Stats/LuckValue

var party_member

var selected_property: String = ""
var selected_button: Button = null

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and self.element_has_focus():
		self.set_process_unhandled_input(false)
		emit_signal("focus_released")
		get_viewport().set_input_as_handled()
		
func on_party_member_focused(focused_party_member):
	if focused_party_member != null:
		self.party_member = focused_party_member
		update_ui_info()

func on_party_member_selected(selected_party_member):
	if selected_party_member != null:
		on_party_member_focused(selected_party_member)
		self.set_process_unhandled_input(true)
		weapon_name.grab_focus()
		weapon_name.grab_click_focus()
	
func update_ui_info():
	set_text(weapon_name, party_member.equipped_weapon, "name", "--")
	set_text(weapon_stats, party_member.equipped_weapon, "attack", "0")
	set_text(helmet_name, party_member.equipped_helmet, "name", "--")
	set_text(helmet_stats, party_member.equipped_helmet, "defense", "0")
	set_text(armor_name, party_member.equipped_armor, "name", "--")
	set_text(armor_stats, party_member.equipped_armor, "defense", "0")
	set_text(accessory_name, party_member.equipped_accessory, "name", "--")
	
	var battler = party_member.battler
	attack_value.text = str(battler.stats.attack)
	defense_value.text = str(battler.stats.defense)
	magic_attack_value.text = str(battler.stats.magic_attack)
	magic_defense_value.text = str(battler.stats.magic_defense)
	speed_value.text = str(battler.stats.speed)
	luck_value.text = str(battler.stats.luck)

func element_has_focus() -> bool:
	return (weapon_name.has_focus() or helmet_name.has_focus() or 
	armor_name.has_focus() or accessory_name.has_focus())
	
func set_text(control: Control, item: Equipment, attribute: String, default: String):
	if item != null and item.get(attribute) != null:
		control.text = str(item.get(attribute))
	else:
		control.text = default
		
func on_weapon_clicked():
	emit_signal(
		"item_requested", 
		Weapon, 
		party_member
	)
	selected_property = "equipped_weapon"
	selected_button = weapon_name
	
func on_helmet_clicked():
	emit_signal(
		"item_requested", 
		Helmet, 
		party_member
	)
	selected_property = "equipped_helmet"
	selected_button = helmet_name
	
func on_armor_clicked():
	emit_signal(
		"item_requested", 
		Armor, 
		party_member
	)
	selected_property = "equipped_armor"
	selected_button = armor_name
	
func on_accessory_clicked():
	emit_signal(
		"item_requested", 
		Accessory, 
		party_member
	)
	selected_property = "equipped_accessory"
	selected_button = accessory_name
	
func on_item_selected(item: Equipment):
	if item != null and selected_property != null and party_member != null:
		#FIXME move inventory logic here
		party_member.set(selected_property, item)
		update_ui_info()
		
func on_grab_focus():
	if selected_button != null:
		selected_button.button_pressed = false
		selected_button.grab_click_focus()
		selected_button.grab_focus()
		selected_button = null
	else:
		weapon_name.grab_click_focus()
		weapon_name.grab_focus()

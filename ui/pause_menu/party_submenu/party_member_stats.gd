extends PanelContainer


onready var weapon_name = $Panel/MarginContainer/Equipment/WeaponName
onready var weapon_stats = $Panel/MarginContainer/Equipment/WeaponStats
onready var helmet_name = $Panel/MarginContainer/Equipment/HelmetName
onready var helmet_stats = $Panel/MarginContainer/Equipment/HelmetStats
onready var armor_name = $Panel/MarginContainer/Equipment/ArmorName
onready var armor_stats = $Panel/MarginContainer/Equipment/ArmorStats
onready var accessory_name = $Panel/MarginContainer/Equipment/AccessoryName

onready var attack_value = $Panel/Stats/AttackValue
onready var defense_value = $Panel/Stats/DefenseValue
onready var magic_attack_value = $Panel/Stats/MagicAttackValue
onready var magic_defense_value = $Panel/Stats/MagicDefenseValue
onready var speed_value = $Panel/Stats/SpeedValue
onready var luck_value = $Panel/Stats/LuckValue

var party_member: PartyMember


func on_party_member_selected(new_party_member: PartyMember):
	on_party_member_focused(new_party_member)
	weapon_name.grab_focus()
	weapon_name.grab_click_focus()
	
	
func on_party_member_focused(new_party_member: PartyMember):
	self.party_member = new_party_member
	self.update_ui()
	
func update_ui():
	
	set_text(weapon_name, self.party_member.equipped_weapon, 'name')
	set_text(weapon_stats, self.party_member.equipped_weapon, 'attack')
	set_text(helmet_name, self.party_member.equipped_helmet, 'name')
	set_text(helmet_stats, self.party_member.equipped_helmet, 'defense')
	set_text(armor_name, self.party_member.equipped_armor, 'name')
	set_text(armor_stats, self.party_member.equipped_armor, 'defense')
	set_text(accessory_name, self.party_member.equipped_accessory, 'name')
	
	attack_value.text = str(self.party_member.stats.attack)
	defense_value.text = str(self.party_member.stats.defense)
	magic_attack_value.text = str(self.party_member.stats.magic_attack)
	magic_defense_value.text = str(self.party_member.stats.magic_defense)
	speed_value.text = str(self.party_member.stats.speed)
	luck_value.text = str(self.party_member.stats.luck)

func set_text(control: Control, item: Equipment, attribute: String):
	if item != null and item.get(attribute) != null:
		control.text = str(item.get(attribute))
	else:
		control.text = '--'

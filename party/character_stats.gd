# Represents a Battler's actual stats: health, strength, etc.
# See the child class GrowthStats.gd for stats growth curves
# and lookup tables
extends Resource

class_name CharacterStats

signal health_changed(new_health, old_health)
signal health_depleted
signal energy_changed(new_energy, old_energy)
signal energy_depleted

var modifiers = {}

var health: int
var energy: int setget set_energy
export var max_health: int = 1 setget set_max_health, _get_max_health
export var max_energy: int = 0 setget set_max_energy, _get_max_energy

export var attack: int = 1 setget , _get_attack
export var defense: int = 1 setget , _get_defense
export var magic_attack: int = 1 setget , _get_magic_attack
export var magic_defense: int = 1 setget , _get_magic_defense
export var luck: int = 1 setget , _get_luck
export var speed: int = 1 setget , _get_speed


var is_alive: bool setget , _is_alive
var level: int


func reset():
	health = self.max_health
	energy = self.max_energy


func copy() -> CharacterStats:
	# Perform a more accurate duplication, as normally Resource duplication
	# does not retain any changes, instead duplicating from what's registered
	# in the ResourceLoader
	var copy = duplicate()
	copy.health = health
	copy.energy = energy
	return copy


func take_damage(hit):
	var old_health = health
	health -= hit.damage
	health = max(0, health)
	emit_signal("health_changed", health, old_health)
	if health == 0:
		emit_signal("health_depleted")


func heal(amount: int):
	var old_health = health
	health = min(health + amount, max_health)
	emit_signal("health_changed", health, old_health)


func set_energy(value: int):
	var old_energy = energy
	energy = max(0, value)
	emit_signal("energy_changed", energy, old_energy)
	if energy == 0:
		emit_signal("energy_depleted")


func set_max_health(value: int):
	if value == null:
		return
	max_health = max(1, value)


func set_max_energy(value: int):
	if value == null:
		return
	max_energy = max(0, value)


func add_modifier(id: int, modifier):
	modifiers[id] = modifier


func remove_modifier(id: int):
	modifiers.erase(id)


func _is_alive() -> bool:
	return health >= 0


func _get_max_health() -> int:
	return max_health


func _get_max_energy() -> int:
	return max_energy


func _get_attack() -> int:
	return attack


func _get_defense() -> int:
	return defense


func _get_magic_attack() -> int:
	return magic_attack


func _get_magic_defense() -> int:
	return magic_attack


func _get_luck() -> int:
	return luck


func _get_speed() -> int:
	return speed


func _get_level() -> int:
	return level

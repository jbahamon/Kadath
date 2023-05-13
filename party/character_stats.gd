# Represents a Battler's actual stats: health, strength, etc.
# See the child class GrowthStats.gd for stats growth curves
# and lookup tables
extends Resource

class_name CharacterStats

var health: int
var energy: int : set = set_energy
@export var max_health: int = 1
@export var max_energy: int = 0

@export var attack: int = 1
@export var defense: int = 1
@export var magic_attack: int = 1
@export var magic_defense: int = 1
@export var luck: int = 1
@export var speed: int = 1

var is_alive: bool : get = _is_alive
var level: int

func _init():
	reset()

func reset():
	health = self.max_health
	energy = self.max_energy

func take_damage(damage: float):
	health -= ceil(damage)
	health = clamp(health, 0, max_health)

func heal(amount: int):
	health = clamp(health + amount, 0, max_health)

func set_energy(value: int):
	energy = clamp(value, 0, max_energy)

func set_max_health(value: int):
	if value == null:
		return
	max_health = max(1, value)

func set_max_energy(value: int):
	if value == null:
		return
	max_energy = max(0, value)

func _is_alive() -> bool:
	return health > 0


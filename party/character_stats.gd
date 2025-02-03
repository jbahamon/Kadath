# Represents a Battler's actual stats: health, strength, etc.
# See the child class GrowthStats.gd for stats growth curves
# and lookup tables
extends Resource

class_name CharacterStats


@export var max_health: int = 1
@export var max_energy: int = 0

@export var attack: int = 1
@export var defense: int = 1
@export var magic_attack: int = 1
@export var magic_defense: int = 1
@export var luck: int = 1
@export var speed: int = 1

var level: int

func set_max_health(value: int):
	if value == null:
		return
	max_health = max(1, value)

func set_max_energy(value: int):
	if value == null:
		return
	max_energy = max(0, value)

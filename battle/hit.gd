extends Resource

class_name Hit

const uniform_add: Material = preload("res://utils/material/uniform_add.tres")

enum Element {
	PHYSICAL,
	
	METAL,
	WOOD,
	FIRE,
	EARTH,
	WATER,
	
	ABYSS,
	CHAOS,
	NONE,
}

@export var animation_only = false

@export_group("Damage")
@export var fixed_damage = false
@export var base_damage: float = 0
@export var type: Element = Element.NONE
@export var energy_drain: int = 0

@export_group("Animation")
@export var anim_time: float = 0
@export var anim_duration: float = 0.45

@export_group("Spark")
@export var spark_frames: SpriteFrames
@export var spark_time: float
@export var spark_offset: Vector2

@export_group("Shake")
@export var shake_time: float = 0.0
@export var shake_duration: float = 0.5
@export var shake_amplitude: Vector2 = Vector2(8, 0)
@export var shake_time_scale: float = 2.0

@export_group("Sound")
@export var hit_sound: AudioStream
@export var hit_sound_time: float
@export var miss_sound: AudioStream
@export var miss_sound_time: float

@export_group("PalFX")
@export var palfx_material: Material = uniform_add
@export var palfx_time = 0.0
@export var palfx_duration = 0.3

@export_group("Toast")
@export var toast_time = 0.3

var offensive_damage_factor: float = 1.0
var effective_damage: int
var effective_energy_drain: int

var potential_damage: float:
	get:
		if self.fixed_damage:
			return self.base_damage
		return base_damage * offensive_damage_factor
			

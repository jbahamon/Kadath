extends Resource
class_name GrowthStats

@export var experience_curve: Curve
@export var max_health_curve: Curve
@export var max_energy_curve: Curve
@export var attack_curve: Curve
@export var defense_curve: Curve
@export var magic_attack_curve: Curve
@export var magic_defense_curve: Curve
@export var speed_curve: Curve

var level_lookup: PackedInt32Array

var initialized = false

func initialize():
	self.level_lookup = PackedInt32Array()
	self.level_lookup.resize(int(experience_curve.max_domain - 2))
	for i in range(2, int(experience_curve.max_domain)):
		# We skip levels 0 and 1 because characters should start at 1.
		# so the index is offset by 2 ;p
		self.level_lookup[i - 2] = int(experience_curve.sample_baked(i))
	
func create_stats(experience: int) -> CharacterStats:
	# Creates and returns a CharacterStats Resource with stats
	# calculated based on the character's experience
	var stats := CharacterStats.new()
	stats.level = get_level(experience)
	stats.max_health = _get_max_health(experience)
	stats.max_energy = _get_max_energy(experience)
	stats.attack = _get_attack(experience)
	stats.defense = _get_defense(experience)
	stats.magic_attack = _get_magic_attack(experience)
	stats.magic_defense = _get_magic_defense(experience)
	stats.speed = _get_speed(experience)
	
	return stats


func get_level(experience: int) -> int:
	var max_level: int = len(level_lookup)
	assert(max_level > 0)
	var level: int = 0
	while level < max_level && experience >= level_lookup[level]:
		level += 1
	return level + 1

func get_experience_for_level_up(level, experience) -> int:
	var max_level: int = len(level_lookup)
	assert(max_level > 0)
	if level >= max_level:
		return 0
	else:
		return level_lookup[level - 1] - experience

func _get_max_health(experience: int) -> int:
	assert(max_health_curve != null)
	var level: float = get_level(experience)
	return int(max_health_curve.sample_baked(level))


func _get_max_energy(experience: int) -> int:
	return _get_stat(max_energy_curve, experience)

func _get_attack(experience: int) -> int:
	return _get_stat(attack_curve, experience)

func _get_defense(experience: int) -> int:
	return _get_stat(defense_curve, experience)

func _get_magic_attack(experience: int) -> int:
	return _get_stat(magic_attack_curve, experience)

func _get_magic_defense(experience: int) -> int:
	return _get_stat(magic_defense_curve, experience)

func _get_speed(experience: int) -> int:
	return _get_stat(speed_curve, experience)

func _get_stat(stat_curve: Curve, experience: int) -> int:
	assert(stat_curve != null)
	var level: float = get_level(experience)
	return round(stat_curve.sample_baked(level))

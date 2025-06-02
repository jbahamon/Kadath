extends "./healing_item.gd"

@export var revival_symbol: SpriteFrames
@export var symbol_offset: Vector2
@export var symbol_duration: float
@export var channel_sound: AudioStream

func get_targets_custom(actor, actors):
	return actor.get_allies(actors).filter(func (it): return not it.is_alive)

func use_in_battle(targets: Array):
	# To avoid frustration, we prevent revival with 0 energy ;P
	self.energy = 1 if targets[0].energy <= 0 else 0
		
	# We assume it's one target because revival items works that way
	FXService.play_sfx_at(channel_sound, targets[0].global_position + symbol_offset)
	await FXService.play_gfx_at(revival_symbol, targets[0].global_position, symbol_offset, symbol_duration)
	return await super.use_in_battle(targets)

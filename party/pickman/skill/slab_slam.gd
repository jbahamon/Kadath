extends "res://battle/action/line_to_target.gd"

@export var channel_sound: AudioStream
@export var throw_sound: AudioStream
@export var jump_sound: AudioStream

@export var animation_hit: Hit
@export var main_hit: Hit
@export var secondary_hit: Hit
@onready var weapon: AnimatedSprite2D = get_node("../../../Weapon")

func execute(actor):
	actor.battler.spend_energy(self.energy_cost)
	var targets = await self.line_of_effect.get_actors_in_line(actor.global_position, self.target.global_position)
	var original_position = actor.global_position
	var original_weapon_offset = weapon.offset
	
	await self.throw_weapon(actor)
	
	await DoAll.new([
		func(): await self.weapon_bounce(),
		func(): await self.jump(actor)
	]).execute()
	
	await self.fall(actor)
	
	await DoAll.new([
		func(): await self.do_hits(actor, targets),
		func(): await self.jump_back(actor, original_position, original_weapon_offset)
	]).execute()
	
	self.reset()
	
func throw_weapon(actor):
	var orientation = actor.global_position.direction_to(target.global_position)
	actor.set_orientation(orientation)
	actor.play_anim("slam_start")
	FXService.play_sfx_at(self.channel_sound, actor.global_position)
	await FXService.shake(actor.anim, 0.67, Vector2(8,8), 4.0, FXService.DecayMode.NONE).shake_finished

	FXService.play_sfx_at(self.throw_sound, actor.global_position)
	weapon.play("spin")
	FXService.play_sfx_at(self.jump_sound, actor.global_position)
	await self.shoot_projectile(
		actor,
		weapon,
		{
			"origin": actor.global_position + self.get_starting_position(actor),
			"destination": target.global_position + Vector2(0, 1),
			"speed": 300.0,
			"skip_reset": true,
		}
	)
	
	target.battler.take_hit(actor, animation_hit)
	await actor.get_tree().create_timer(0.2).timeout

func weapon_bounce():
	var tween = weapon.get_tree().create_tween()
	tween.tween_property(weapon, "offset:y", -75, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.finished

func jump(actor):
	actor.play_anim("slam_jump")
	await actor.get_tree().create_timer(0.2).timeout
	FXService.play_sfx_at(self.jump_sound, actor.global_position)
	var tween: Tween = actor.get_tree().create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(actor, "global_position", target.global_position, 0.6)
	tween.tween_property(actor.anim, "position", Vector2(0, -80), 0.6)
	await tween.finished
	
func fall(actor):
	var room = EnvironmentService.get_room()
	room.remove_child(weapon)
	actor.battler.add_child(weapon)
	actor.battler.move_child(weapon, 0)
	weapon.offset = Vector2.ZERO
	weapon.position = actor.anim.position + Vector2(0, -5)
	actor.play_anim("slam_hit")
	weapon.play("slam")
	
	var tween: Tween = actor.get_tree().create_tween().set_parallel()
	tween.tween_property(actor.anim, "position", Vector2.ZERO, 0.3)
	tween.tween_property(weapon, "position", Vector2(0, -5), 0.3)
	await tween.finished
	await target.battler.take_hit(actor, animation_hit)
	
func jump_back(actor, original_position, weapon_offset):
	weapon.visible = false
	weapon.offset = weapon_offset
	weapon.position = Vector2.ZERO
	
	actor.play_anim("jump_back")
	await actor.move_to([original_position.x, original_position.y], 200)
	actor.play_anim("battle_idle")

func do_hits(actor, targets):
	main_hit.offensive_damage_factor = self.default_offensive_damage_factor(actor.battler, main_hit)
	secondary_hit.offensive_damage_factor = self.default_offensive_damage_factor(actor.battler, secondary_hit)
			
	var hits = [
		func (): await self.target.take_hit(actor, main_hit)
	]
	
	var additional_hits = targets.filter(
		func(line_target): return line_target is not PartyMember and line_target != self.target
	).map(
		func (line_target):
			return func (): await line_target.take_hit(actor, secondary_hit)
	)
	hits.append_array(additional_hits)
	await DoAll.new(hits).execute()

func get_starting_position(actor):
	match VarsService.round_orientation_with_bias(actor.current_orientation):
		Vector2.UP:
			return Vector2(0, -18)
		Vector2.DOWN:
			return Vector2(0, 6)
		Vector2.LEFT:
			return Vector2(-21, -12)
		Vector2.RIGHT:
			return Vector2(21, -12)
			
	

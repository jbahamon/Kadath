extends "res://battle/action/simple_single_target.gd"

@onready var beam: AnimatedSprite2D = get_node("../../Beam")

@export var hit: Hit

const OPEN_EYE_DURATION = 0.6

func execute(actor):
	BattleService.announce(self.description)
	var original_position = actor.global_position
	var target_position = Vector2(target.global_position.x, original_position.y)
	
	if target_position.x > original_position.x:
		actor.play_anim("walk_right_2")
	else:
		actor.play_anim("walk_left_2")
	
	await actor.move_to([target_position.x, target_position.y], 120)
	
	actor.play_anim("open_eye")
	await get_tree().create_timer(OPEN_EYE_DURATION).timeout
	await self.shoot_beam(actor)
	BattleService.announce("")
	if target_position.x > original_position.x:
		actor.play_anim("walk_left_2")
	else:
		actor.play_anim("walk_right_2")
		
	await actor.move_to([original_position.x, original_position.y], 120)
	
	actor.play_anim("idle")
	self.reset()

func shoot_beam(actor):
	beam.visible = true
	beam.play(&"default")
	
	await DoAll.new([
		func():
			#await get_tree().create_timer(0.3).timeout
			await CameraService.shake(CutsceneInstruction.ExecutionMode.PLAY, 0.8, Vector2(0, 8), 3.0),
		func():
			await beam.animation_finished
			actor.play_anim("close_eye")
			beam.visible = false,
		func (): await target.take_hit(actor, self.hit)
	]).execute()
	

extends "res://battle/action/simple_single_target.gd"

@onready var tendrils: AnimatedSprite2D = get_node("../../Tendrils")
@export var hit: Hit

	
func execute(actor):
	actor.play_anim("attack")
	await actor.get_tree().create_timer(0.2)
	
	var center = target.battler.get_hitspot("Center")
	tendrils.global_position = target.global_position
	tendrils.offset = Vector2(0, center.y - tendrils.global_position.y)
	
	tendrils.play("windup")
	tendrils.visible = true
	
	await tendrils.animation_finished
	tendrils.play("attack")
	
	var tree = get_tree()
	
	await DoAll.new([
		func(): await self.target.take_hit(actor, hit),
		func():
			await tree.create_timer(0.6).timeout
			tendrils.play_backwards("windup")
			await tendrils.animation_finished
			tendrils.visible = false
			tendrils.position = Vector2.ZERO
	]).execute()
	
	actor.play_anim("idle")
	self.reset()

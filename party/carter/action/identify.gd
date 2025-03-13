extends "res://battle/action/simple_single_target.gd"

@export_multiline var long_description: String
@export var scan_sound: AudioStream
@export var success_sound: AudioStream
@export var radius: int = 16
@export  var base_offset: Vector2
@onready var glass: Sprite2D = $MagnifyingGlass

func execute(actor):
	actor.play_anim("identify")
	await actor.get_tree().create_timer(0.5).timeout
	var enemy_id = self.target.enemy_id
	var room = EnvironmentService.get_room()
	
	self.remove_child(glass)
	room.add_child(glass)
	FXService.play_sfx_at(scan_sound, self.target.global_position + Vector2(0, -self.target.height/2.0))
	glass.position = self.target.global_position
	var tween: Tween = actor.get_tree().create_tween()
	tween.tween_method(self.set_angle, -PI/2.0, 7*PI/2.0, 1.6)
	glass.visible = true 
	await tween.finished
	
	VarsService.scan_enemy(enemy_id)
	glass.visible = false
	UIService.play_notification(self.success_sound)
	await BattleService.show_enemy_info(self.target)
	await actor.get_tree().create_timer(0.5).timeout
	actor.play_anim("battle_idle")
	self.reset()
	
func set_angle(angle):
	self.glass.offset = Vector2(self.base_offset.x, -self.target.height/2.0) + Vector2.DOWN.rotated(angle) * self.radius

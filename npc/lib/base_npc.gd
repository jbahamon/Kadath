extends CharacterBody2D
class_name BaseNPC

var RandomSpinMovement = preload("./movement/random_spin_movement.tscn")
var dissolve_shader = preload("res://utils/material/dissolve.gdshader")
var death_sound = preload("res://sound/fx/death/Default - harvey656.wav")

signal resumed
signal move_to_done

enum MovementType { 
	NONE = 0,
	RANDOM_SPIN = 1,
	CUSTOM = 2, 
}

const WALK_SPEED = 100.0

@export var base_display_name: String
@export var dialogue_name: String = ""
@export var movement_type: MovementType = MovementType.NONE
@export var custom_movement: NodePath
@export var starting_orientation = Vector2.DOWN

@onready var anim = $Anim
@onready var bump_collision: CollisionShape2D = $BumpCollision
@onready var interactable_area: Area2D = $InteractableArea

var display_name: String:
	get:
		return self.get_display_name()
		
var movement_node: NPCMovement
var move_timer = null

var current_orientation: Vector2:
	get:
		return self.anim.current_orientation
		

func _ready():
	match movement_type:
		MovementType.NONE:
			movement_node = NPCMovement.new()
			movement_node.parent = self
		MovementType.RANDOM_SPIN:
			movement_node = RandomSpinMovement.instantiate()
			movement_node.parent = self
			movement_node.period += randf()
		MovementType.CUSTOM:
			movement_node = get_node(custom_movement)
		_:
			pass
	self.set_orientation(starting_orientation)
	self.start_auto_movement()
	
func _physics_process(delta):
	self.move_and_collide(velocity * delta)

func get_display_name():
	return self.base_display_name

# Animatable interface

func play_anim(anim_name: String):
	self.anim.play_anim(anim_name)
	
func has_anim(anim_name: String) -> bool:
	return self.anim.has_anim(anim_name)
	
	
func set_orientation(orientation: Vector2):
	self.anim.set_orientation(orientation)
	
func on_proxy_enter(_proxy):
	self.set_physics_process(false)
	self.stop_auto_movement()
	self.bump_collision.disabled = true
	self.interactable_area.monitoring = false
	
func on_proxy_leave(_proxy):
	self.set_physics_process(true)
	self.start_auto_movement()
	self.bump_collision.disabled = false
	self.interactable_area.monitoring = false

func on_player_interaction(player_proxy: PlayerProxy):
	if self.dialogue_name == "":
		return
	
	self.set_orientation(
		self.global_position.direction_to(player_proxy.global_position).normalized()
	)
	self.stop_auto_movement()
	self.interactable_area.monitoring = false
	
	var was_input_enabled = InputService.input_enabled
	player_proxy.set_mode(PlayerProxy.ProxyMode.CUTSCENE)
	InputService.input_enabled = false
	
	await DialogueService.open_dialogue(self.dialogue_name)
	
	InputService.input_enabled = was_input_enabled
	player_proxy.set_mode(PlayerProxy.ProxyMode.GAMEPLAY)
	self.interactable_area.monitoring = true
	self.start_auto_movement()

func fade(_mode: CutsceneInstruction.ExecutionMode):
	self.queue_free()
	
func die(mode: CutsceneInstruction.ExecutionMode):
	if mode == CutsceneInstruction.ExecutionMode.PLAY:
		FXService.play_sfx_at(death_sound, self.position)
		var fade_tween = get_tree().create_tween()
		var dissolve_material = ShaderMaterial.new()
		dissolve_material.shader = dissolve_shader
		self.material = dissolve_material
		dissolve_material.set_shader_parameter("progress", 0.0)
		fade_tween.tween_property(dissolve_material, "shader_parameter/progress", 1.0, 0.75)
		await fade_tween.finished
	
	self.queue_free()

func stop_auto_movement():
	self.velocity = Vector2.ZERO
	self.set_physics_process(true)
	self.movement_node.stop()
	
func start_auto_movement():
	self.set_physics_process(false)
	self.movement_node.start()

func move_to(target: Array, speed = WALK_SPEED):
	assert(speed > 0)
	var target_position = Vector2(
		target[0] if !is_nan(target[0]) else self.global_position.x,
		target[1] if !is_nan(target[1]) else self.global_position.y
	)
	var was_processing_physics = self.is_physics_processing()
	
	self.stop_auto_movement()
	if self.global_position != target_position:
		self.resume_move_to(target, speed)
		await self.move_to_done

	self.move_timer = null
	self.global_position = target_position
	self.velocity = Vector2.ZERO
	self.set_physics_process(was_processing_physics)

func pause_move_to():
	if self.move_timer != null:
		self.move_timer.timeout.disconnect(self.on_move_timer_done)

func resume_move_to(target: Array, speed):
	var target_position = Vector2(
		target[0] if !is_nan(target[0]) else self.global_position.x,
		target[1] if !is_nan(target[1]) else self.global_position.y
	)
	var time = (self.global_position - target_position).length()/speed
	
	if time > 0:
		self.velocity = (target_position - self.global_position).normalized() * speed
		self.move_timer = self.get_tree().create_timer(time, false)
		self.move_timer.timeout.connect(self.on_move_timer_done, CONNECT_ONE_SHOT)
	else:
		self.move_to_done.emit()

func skip_move_to():
	self.move_to_done.emit()
	
func on_move_timer_done():
	self.move_to_done.emit()

func disable_collisions():
	self.bump_collision.disabled = true
	
func enable_collisions():
	self.bump_collision.disabled = false

func pause():
	var was_colliding = not self.bump_collision.disabled
	var was_processing_physics = self.is_physics_processing()
	self.set_physics_process(false)
	await self.resumed
	
	if was_colliding:
		self.enable_collisions()
	
	if was_processing_physics:
		self.set_physics_process(true)

func resume():
	self.resumed.emit()
	
func on_battle_start():
	self.stop_auto_movement()
	self.interactable_area.set_deferred("monitoring", true)

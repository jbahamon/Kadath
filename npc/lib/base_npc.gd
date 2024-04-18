extends CharacterBody2D
class_name BaseNPC

var NPCMovement = preload("./movement/npc_movement.tscn")
var RandomSpinMovement = preload("./movement/random_spin_movement.tscn")

signal resumed
signal move_to_done

enum MovementType { 
	NONE = 0,
	RANDOM_SPIN = 1,
	CUSTOM = 2, 
}

const WALK_SPEED = 100.0

@export var display_name: String
@export var dialogue_name: String = ""
@export var movement_type: MovementType = MovementType.NONE
@export var custom_movement: NodePath
@export var starting_orientation = Vector2.DOWN

@onready var anim = $Anim
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var interactable_collision: CollisionShape2D = $InteractableArea/CollisionShape2D

var movement_node: NPCMovement
var move_timer = null

func _ready():
	match movement_type:
		MovementType.NONE:
			movement_node = NPCMovement.instantiate()
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

# Animatable interface

func play_anim(anim_name: String):
	self.anim.play_anim(anim_name)
	
func set_orientation(orientation: Vector2):
	self.anim.set_orientation(orientation)
	
func on_proxy_enter(_proxy):
	self.set_physics_process(false)
	self.stop_auto_movement()
	self.collision.disabled = true
	self.interactable_collision.disabled = true
	
func on_proxy_leave(_proxy):
	self.set_physics_process(true)
	self.start_auto_movement()
	self.collision.disabled = false
	self.interactable_collision.disabled = false

func on_player_interaction(player_proxy: PlayerProxy):
	if self.dialogue_name == "":
		return
	
	self.set_orientation(
		self.global_position.direction_to(player_proxy.global_position).normalized()
	)
	self.stop_auto_movement()
	self.interactable_collision.set_disabled(true)
	
	var was_input_enabled = InputService.is_input_enabled()
	player_proxy.set_mode(PlayerProxy.ProxyMode.CUTSCENE)
	InputService.set_input_enabled(false)
	
	await DialogueService.open_dialogue(self.dialogue_name)
	
	InputService.set_input_enabled(was_input_enabled)
	player_proxy.set_mode(PlayerProxy.ProxyMode.GAMEPLAY)
	self.interactable_collision.set_disabled(false)
	self.start_auto_movement()
	
func die(_mode: CutsceneInstruction.ExecutionMode):
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
		target[0] if target[0] != null else self.global_position.x,
		target[1] if target[1] != null else self.global_position.y
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
		target[0] if target[0] != null else self.global_position.x,
		target[1] if target[1] != null else self.global_position.y
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
	self.collision.disabled = true
	
func enable_collisions():
	self.collision.disabled = false

func pause():
	var was_colliding = not self.collision.disabled
	var was_processing_physics = self.is_physics_processing()
	self.set_physics_process(false)
	await self.resumed
	
	if was_colliding:
		self.enable_collisions()
	
	if was_processing_physics:
		self.set_physics_process(true)

func resume():
	self.resumed.emit()
	
func on_enter_battle():
	self.stop_auto_movement()
	self.interactable_collision.call_deferred("set_disabled", true)

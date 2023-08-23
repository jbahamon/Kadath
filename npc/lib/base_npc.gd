extends CharacterBody2D
class_name BaseNPC

var NPCMovement = preload("./movement/npc_movement.tscn")
var RandomSpinMovement = preload("./movement/random_spin_movement.tscn")

signal resumed

enum MovementType { 
	NONE = 0,
	RANDOM_SPIN = 1,
	CUSTOM = 2, 
}

const WALK_SPEED = 100.0

@export var display_name: String
@export var dialog_name: String = ""
@export var movement_type: MovementType = MovementType.NONE
@export var custom_movement: NodePath
@export var starting_orientation = Vector2.DOWN

@onready var anim = $Anim
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var interactable_collision: CollisionShape2D = $InteractableArea/CollisionShape2D

var movement_node: NPCMovement

func _ready():
	match movement_type:
		MovementType.NONE:
			movement_node = NPCMovement.instantiate()
		MovementType.RANDOM_SPIN:
			movement_node = RandomSpinMovement.instantiate()
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
	
func on_proxy_enter():
	self.set_physics_process(false)
	self.stop_auto_movement()
	self.collision.disabled = true
	self.interactable_collision.disabled = true
	
func on_proxy_leave():
	self.set_physics_process(true)
	self.start_auto_movement()
	self.collision.disabled = false
	self.interactable_collision.disabled = false

func on_player_interaction(player_proxy: PlayerProxy):
	if self.dialog_name == "":
		return
	
	self.set_orientation(
		self.global_position.direction_to(player_proxy.global_position).normalized()
	)
	self.stop_auto_movement()
	self.interactable_collision.set_disabled(true)
	
	var was_input_enabled = InputService.is_input_enabled()
	InputService.set_input_enabled(false)
	
	await DialogService.open_dialog(self.dialog_name, self)	
	
	InputService.set_input_enabled(was_input_enabled)
	self.interactable_collision.set_disabled(false)
	self.start_auto_movement()
	
func die():
	self.queue_free()

func stop_auto_movement():
	self.movement_node.stop()
	
func start_auto_movement():
	self.movement_node.start()
	
	

# Battle methods
	
func get_allies(actors: Array):
	var allies = []
	for actor in actors:
		if not actor is PartyMember:
			allies.append(actor)
	return allies
	
func get_enemies(actors: Array):
	var enemies = []
	for actor in actors:
		if actor is PartyMember:
			enemies.append(actor)
	return enemies


func move_to(target: Vector2, speed = WALK_SPEED):
	assert(speed > 0)
	var was_processing_physics = self.is_physics_processing()
	var time = (self.global_position - target).length()/speed
	self.movement_node.stop()
	self.set_physics_process(true)
	self.velocity = (target - self.global_position).normalized() * speed
	await get_tree().create_timer(time).timeout
	self.position = target
	self.velocity = Vector2.ZERO
	self.movement_node.start()
	self.set_physics_process(was_processing_physics)
	
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
	self.emit_signal("resumed")
	

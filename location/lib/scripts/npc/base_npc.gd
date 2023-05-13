extends CharacterBody2D
class_name BaseNPC

var NPCMovement = preload("./movement/npc_movement.tscn")
var RandomSpinMovement = preload("./movement/random_spin_movement.tscn")

enum MovementType { 
	NONE = 0,
	RANDOM_SPIN = 1,
	CUSTOM = 2, 
}

const WALK_SPEED = 100.0

@export var display_name: String
@export var dialog_name: String = "test_message"
@export var dialog_nid: int = 1
@export var movement_type: MovementType = MovementType.NONE
@export var custom_movement: NodePath
@export var facing = Vector2.DOWN

@onready var sprite: Sprite2D = $Sprite2D
@onready var battler: Battler = $Battler
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var interactable_collision: CollisionShape2D = $InteractableArea/CollisionShape2D
var movement_node 

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
	self.add_child(movement_node)
	self.start_auto_movement()
	
	
func _physics_process(delta):
	self.move_and_collide(velocity * delta)

func update_facing():
	animation_tree["parameters/idle/blend_position"] = facing
	animation_tree["parameters/walk/blend_position"] = facing

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
	self.set_orientation(
		self.position.direction_to(player_proxy.position).normalized()
	)
	self.stop_auto_movement()
	self.interactable_collision.set_disabled(false)
	
	var were_inputs_disabled = InputService.disable_inputs()
	
	await DialogService.open_dialog(self.dialog_name, self)
	
	if were_inputs_disabled:
		InputService.enable_inputs()
	self.interactable_collision.set_disabled(false)
	self.start_auto_movement()
	
	
func die():
	self.queue_free()

func stop_auto_movement():
	self.movement_node.set_process(false)
	
func start_auto_movement():
	self.movement_node.set_process(true)

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

func take_hit(hit: Hit):
	self.battler.take_damage(hit)

# Animatable interface

func play_anim(anim_name: String):
	animation_state.travel(anim_name)

func set_orientation(orientation: Vector2):
	self.facing = orientation
	update_facing()

func move_to(target: Vector2, speed = WALK_SPEED):
	assert(speed > 0)
	var was_processing_physics = self.is_physics_processing()
	var time = (self.global_position - target).length()/speed
	self.movement_node.set_process(false)
	self.set_physics_process(true)
	self.velocity = (target - self.global_position).normalized() * speed
	await get_tree().create_timer(time).timeout
	self.velocity = Vector2.ZERO
	self.movement_node.set_process(true)
	self.set_physics_process(was_processing_physics)
	
func disable_collisions():
	self.collision.disabled = true
	
func enable_collisions():
	self.collision.disabled = false

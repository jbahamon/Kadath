extends KinematicBody2D

var NPCMovement = preload("./movement/npc_movement.tscn")
var RandomSpinMovement = preload("./movement/random_spin_movement.tscn")
class_name BaseNPC

enum MovementType { 
	NONE = 0,
	RANDOM_SPIN = 1,
	CUSTOM = 2, 
}

const WALK_SPEED = 100.0

export (String) var display_name
export var dialog_name: String = "test_message"
export var dialog_nid: int = 1
export (MovementType) var movement_type: int = MovementType.NONE
export (NodePath) var custom_movement = null
export var facing = Vector2.DOWN

onready var sprite: Sprite = $Sprite
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var animation_tree: AnimationTree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var collision: CollisionShape2D = $CollisionShape2D
onready var interactable_collision: CollisionShape2D = $InteractableArea/CollisionShape2D

var velocity: Vector2 = Vector2.ZERO

var movement_node 

func _ready():
	match movement_type:
		MovementType.NONE:
			movement_node = NPCMovement.instance()
			continue
		MovementType.RANDOM_SPIN:
			movement_node = RandomSpinMovement.instance()
			movement_node.period += randf()
			continue
		MovementType.CUSTOM:
			movement_node = get_node(custom_movement)
		_:
			self.add_child(movement_node)

	update_facing()

func stop_movement():
	self.movement_node.set_process(false)

func resume_movement():
	self.movement_node.set_process(true)
	
func _physics_process(delta):
	self.move_and_collide(velocity * delta)

func rotate_facing(angle):
	facing = facing.rotated(angle)
	update_facing()
	
	
func update_facing():
	animation_tree["parameters/idle/blend_position"] = facing
	animation_tree["parameters/walk/blend_position"] = facing


func play_anim(animation_name):
	animation_state.travel(animation_name)


func on_player_interaction(player_proxy: PlayerProxy):
	self.look_at(player_proxy.position)
	self.movement_node.set_process(false)
	self.interactable_collision.set_disabled(false)
	
	var local_scene: LocalScene = get_local_scene()
	local_scene.disable_inputs()

	var talk_result = local_scene.open_dialog(self.dialog_name, self.dialog_nid, self)
	
	if talk_result is GDScriptFunctionState:
		talk_result = yield(talk_result, "completed")
	
	local_scene.enable_inputs()
	self.interactable_collision.set_disabled(false)
	self.movement_node.set_process(true)
	
func set_orientation(orientation: Vector2):
	self.facing = orientation
	update_facing()

func look_at(point: Vector2):
	facing = self.position.direction_to(point)

	if abs(facing.x) > abs(facing.y):
		facing.y = 0
	else:
		facing.x = 0
	facing = facing.normalized()
	
	update_facing()


func walk_to(target: Vector2, speed = WALK_SPEED):
	yield(self.movement_node.walk_to(target, speed), "completed")
	
func get_local_scene():
	return get_node("../../../")
	
func get_anim():
	return self
	
func on_proxy_enter():
	self.set_physics_process(false)
	self.movement_node.set_process(false)
	self.collision.disabled = true
	self.interactable_collision.disabled = true
	
func on_proxy_leave():
	self.set_physics_process(true)
	self.movement_node.set_process(true)
	self.collision.disabled = false
	self.interactable_collision.disabled = false

func disable_collisions():
	self.set_physics_process(false)
	self.collision.disabled = true
	
func enable_collisions():
	self.set_physics_process(true)
	self.collision.disabled = false

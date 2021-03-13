extends KinematicBody2D

class_name BaseNPC

export (String) var npc_name
export (Texture) var sprite_sheet
export (int) var hframes = 5
export (int) var vframes = 5
export (Vector2) var sprite_offset = Vector2(12, 33)
export var dialog_name: String = "test_message"
export (NodePath) var movement = null

var facing = Vector2.DOWN

var movement_node 
onready var sprite: Sprite = $Sprite
onready var animation_tree: AnimationTree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var interactable_collision: CollisionShape2D = $InteractableArea/CollisionShape2D

func _ready():
	if movement != null:
		movement_node = get_node(movement)
		var base_movement = $NPCMovement
		remove_child(base_movement)
		base_movement.queue_free()
	else:
		movement_node = $NPCMovement
		
	sprite.texture = sprite_sheet
	sprite.hframes = hframes
	sprite.vframes = vframes
	sprite.offset = -sprite_offset


func rotate_facing(angle):
	facing = facing.rotated(angle)
	update_facing()
	
	
func update_facing():
	animation_tree["parameters/idle/blend_position"] = facing
	animation_tree["parameters/move/blend_position"] = facing


func set_animation(animation_name):
	animation_state.travel(animation_name)


func on_player_interaction(player: Player):
	self.look_at(player.position)
	self.movement_node.set_process(false)
	self.interactable_collision.set_disabled(false)
	player.set_process(false)
	player.set_physics_process(false)
	player.set_process_input(false)
	
	var local_scene: LocalScene = get_local_scene()
	yield(local_scene.talk(self.dialog_name), "completed")
	
	player.set_physics_process(true)
	player.set_process(true)
	player.set_process_input(true)
	self.interactable_collision.set_disabled(false)
	self.movement_node.set_process(true)



func look_at(point: Vector2):
	facing = self.position.direction_to(point)

	if abs(facing.x) > abs(facing.y):
		facing.y = 0
	else:
		facing.x = 0
	facing = facing.normalized()
	
	update_facing()
	
func get_local_scene():
	return get_node("../../../")

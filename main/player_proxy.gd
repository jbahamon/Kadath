extends KinematicBody2D

class_name PlayerProxy

const walk_speed: float = 100.0
const interaction_vector = Vector2(20, 10)

export var anim_path: NodePath

var input_vector = Vector2.ZERO
var velocity = Vector2.ZERO
var party: Party

onready var anim = get_node(anim_path)
onready var raycast: RayCast2D = $RayCast2D
onready var remote_transform: RemoteTransform2D = $RemoteTransform2D
onready var collision: CollisionShape2D = $CollisionShape2D

func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_accept"):
		raycast.force_raycast_update()
		if raycast.is_colliding() and raycast.get_collider().has_method("on_player_interaction"):
			anim.play_anim("idle")
			raycast.get_collider().on_player_interaction(self)
			

func _physics_process(_delta) -> void:
	var input_vector_changed = update_input_vector()
	
	if input_vector_changed:
		update_velocity()
		update_orientation()
		update_animation()
		
	move()

func move() -> void:
	velocity = move_and_slide(velocity)


func update_velocity() -> void:
	if input_vector != Vector2.ZERO:
		velocity = input_vector.normalized() * get_movement_speed()
	else:
		velocity = Vector2.ZERO


func update_input_vector():
	var old_input_vector = input_vector

	input_vector = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	) if self.is_processing_unhandled_input() else Vector2.ZERO
		
	return old_input_vector == input_vector
	
	
func get_movement_speed() -> float:
	return walk_speed


func update_animation() -> void:
	if velocity == Vector2.ZERO:
		anim.play_anim("idle")
	else:
		anim.play_anim("walk")
		
		
func update_orientation() -> void:
	if velocity == Vector2.ZERO:
		return
	self.set_orientation(input_vector)
	

func save(save_data: SaveData) -> void:
	save_data.data["player_position"] = self.position

func set_orientation(orientation: Vector2):
	anim.set_orientation(orientation)

	raycast.set_cast_to(Vector2(
			interaction_vector.x * orientation.x, 
			interaction_vector.y * orientation.y
	))
	
func load(save_data: SaveData) -> void:
	self.position = save_data.data["player_position"]
	
func set_target(new_target: Node):
	self.set_physics_process(false)
	var old_target = self.remote_transform.get_node(self.remote_transform.remote_path)
	
	if old_target.has_method("on_proxy_leave"):
		old_target.on_proxy_leave()
	
	if new_target.has_method("on_proxy_enter"):
		new_target.on_proxy_enter()
	
	self.global_position = new_target.global_position
	self.remote_transform.remote_path = self.remote_transform.get_path_to(new_target)
	self.anim = new_target.get_anim()
	self.anim_path = self.get_path_to(self.anim)
	self.set_physics_process(true)

func set_party(new_party: Party) -> void:
	self.party = new_party


func get_inventory() -> Inventory:
	return self.party.inventory

func disable_collisions():
	self.set_physics_process(false)
	self.collision.disabled = true
	
func enable_collisions():
	self.set_physics_process(true)
	self.collision.disabled = false

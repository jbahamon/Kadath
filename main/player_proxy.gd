extends CharacterBody2D

class_name PlayerProxy

enum ProxyMode {
	GAMEPLAY,
	CUTSCENE,
	NOT_THERE
}

const walk_speed: float = 100.0
const interaction_vector = Vector2(16, 16)

var input_vector = Vector2.ZERO
var automated = false
var target: Node2D
var current_orientation = Vector2.ZERO
var current_mode = ProxyMode.GAMEPLAY

@onready var raycast: RayCast2D = $RayCast2D
@onready var remote_transform: RemoteTransform2D = $RemoteTransform2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	self.set_target(self.remote_transform.get_node_or_null(self.remote_transform.remote_path))

func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_accept"):
		raycast.force_raycast_update()
		if raycast.is_colliding() and raycast.get_collider().has_method("on_player_interaction"):
			self.target.play_anim("idle")
			raycast.get_collider().on_player_interaction(self)

func _physics_process(_delta) -> void:
	if self.current_mode == ProxyMode.GAMEPLAY:
		var input_vector_changed = update_input_vector()
		
		if input_vector_changed:
			update_velocity()
			update_orientation()
			update_animation()
	
	set_velocity(velocity)
	move_and_slide()

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
		self.target.play_anim("idle")
	else:
		self.target.play_anim("walk")
		
func update_orientation() -> void:
	if velocity == Vector2.ZERO:
		return
	self.set_orientation(input_vector)

func save(save_data: SaveData) -> void:
	save_data.data["player_position"] = self.position

func load_game_data(save_data: SaveData) -> void:
	self.position = save_data.data["player_position"]

func set_target(new_target: Node):
	if self.target == new_target:
		return 
	
	var was_processing_physics = self.is_physics_processing()
	self.set_physics_process(false)
	
	if self.target and self.target.has_method("on_proxy_leave"):
		self.target.on_proxy_leave()
	
	self.target = new_target
	
	if self.target and self.target.has_method("on_proxy_enter"):
		self.target.on_proxy_enter()
	
	self.global_position = self.target.global_position
	self.remote_transform.remote_path = self.remote_transform.get_path_to(self.target)
	self.set_physics_process(was_processing_physics)

func get_display_name() -> String:
	assert(self.target != null)
	return self.target.display_name
	
func _set_process_collisions(value: bool):
	self.collision.set_deferred("disabled", not value)

func move_to(target_position: Vector2, speed):
	assert(speed > 0)
	var previous_mode = self.current_mode
	self.set_mode(ProxyMode.CUTSCENE)
	var time = (global_position - target_position).length()/speed
	self.velocity = (target_position - global_position).normalized() * speed
	await get_tree().create_timer(time).timeout
	self.position = target_position
	self.velocity = Vector2.ZERO
	self.set_mode(previous_mode)

func play_anim(anim_name: String):
	self.target.play_anim(anim_name)
	
func set_orientation(orientation: Vector2):
	if current_orientation == orientation:
		return
	current_orientation = orientation
	self.target.set_orientation(orientation)

	raycast.set_target_position(Vector2(
		interaction_vector.x * orientation.x, 
		interaction_vector.y * orientation.y
	))

func set_mode(mode: ProxyMode):
	self.current_mode = mode
	match(self.current_mode):
		ProxyMode.GAMEPLAY:
			self.set_physics_process(true)
			self.set_process_unhandled_input(true)
			self._set_process_collisions(true)
			self.target.set_orientation(current_orientation)
		ProxyMode.CUTSCENE:
			self.velocity = Vector2.ZERO
			self.set_physics_process(true)
			self.set_process_unhandled_input(false)
			self._set_process_collisions(true)
		ProxyMode.NOT_THERE:
			self.set_physics_process(false)
			self.set_process_unhandled_input(false)
			self._set_process_collisions(false)
			
			
		

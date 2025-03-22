extends CharacterBody2D

class_name PlayerProxy

enum ProxyMode {
	GAMEPLAY,
	CUTSCENE,
	NOT_THERE
}
enum TargetType {
	PARTY,
	OTHER
}

@export var walk_speed: float = 60.0
@export var run_speed: float = 120.0

@export var interaction_vector_length = 16

var is_running = false
var input_vector = Vector2.ZERO
var target: Node2D
var current_orientation = Vector2.ZERO
var current_mode = ProxyMode.GAMEPLAY
var current_target_type = TargetType.PARTY

var move_timer = null

@onready var raycast: RayCast2D = $RayCast2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var remote_transform: RemoteTransform2D = $RemoteTransform2D
@onready var height = $CollisionShape2D.shape.height

var top_position:
	get: 
		return self.position + Vector2(0, -self.height)

func _init() -> void:
	self.set_physics_process(false)
	self.set_process_unhandled_input(false)
	
func _unhandled_input(event) -> void:
	if event.is_action_pressed(&"ui_accept"):
		self.raycast.force_raycast_update()
		if self.raycast.is_colliding():
			self.target.play_anim("idle")
			raycast.get_collider().on_player_interaction(self)
		self.get_viewport().set_input_as_handled()
		
func _physics_process(_delta) -> void:
	if self.current_mode == ProxyMode.GAMEPLAY:
		var input_vector_changed = update_input_vector()
		
		if input_vector_changed:
			update_velocity()
			update_orientation()
			update_animation()
	
	set_velocity(velocity)
	move_and_slide()
	
	self.update_raycast()

func update_velocity() -> void:
	if input_vector != Vector2.ZERO:
		velocity = input_vector.normalized() * get_movement_speed()
	else:
		velocity = Vector2.ZERO
		
func update_raycast():
	if self.raycast.is_colliding():
		EntitiesService.interaction_indicator.visible = true
		EntitiesService.interaction_indicator.global_position = raycast.get_collider().global_position
	else:
		EntitiesService.interaction_indicator.visible = false

func update_input_vector():
	var old_input_vector = input_vector
	
	input_vector = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	) if self.is_processing_unhandled_input() else Vector2.ZERO
		
	return old_input_vector == input_vector

func get_movement_speed() -> float:
	if SettingsService.toggle_run:
		if Input.is_action_just_pressed("action_run"):
			self.is_running = not self.is_running
	else:
		self.is_running = Input.is_action_pressed("action_run")

	return self.run_speed if self.is_running else self.walk_speed

func update_animation() -> void:
	if not self.target:
		return
	if velocity == Vector2.ZERO:
		self.target.play_anim("idle")
	elif self.is_running:
		self.target.play_anim("run")
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

func set_target(new_target: Node, force: bool = false):
	if self.target == new_target and not force:
		return 
	
	var was_processing_physics = self.is_physics_processing()
	self.set_physics_process(false)
	
	if self.target and self.target.has_method("on_proxy_leave"):
		self.target.on_proxy_leave(self)
	
	self.current_target_type = TargetType.PARTY if new_target is Party else TargetType.OTHER
	
	match(self.current_target_type):
		TargetType.PARTY:
			self.target = new_target.get_leader()
		TargetType.OTHER:
			self.target = new_target
	
	if self.target and self.target.has_method("on_proxy_enter"):
		self.target.on_proxy_enter(self)

	if self.target:
		self.global_position = self.target.global_position
		var path = self.remote_transform.get_path_to(self.target)
		self.remote_transform.remote_path = path
	self.set_physics_process(was_processing_physics)

func get_display_name() -> String:
	assert(self.target != null)
	return self.target.display_name
	
func _set_process_collisions(value: bool):
	self.raycast.enabled = value
	self.update_raycast()
	self.collision.set_deferred("disabled", not value)

func move_to(move_target: Array, speed):
	assert(speed > 0)
	var previous_mode = self.current_mode
	self.set_mode(ProxyMode.CUTSCENE)
	
	var target_position = Vector2(
		move_target[0] if move_target[0] != null else self.global_position.x,
		move_target[1] if move_target[1] != null else self.global_position.y
	)
	var time = max((self.global_position - target_position).length()/speed - 1/30.0, 0)
	
	if time > 0:
		self.velocity = (target_position - self.global_position).normalized() * speed
		self.move_timer = self.get_tree().create_timer(time, false)
		await self.move_timer.timeout
	
	self.move_timer = null
	self.global_position = target_position
	self.velocity = Vector2.ZERO
	self.set_mode(previous_mode)

func skip_move_to():
	if self.move_timer != null:
		self.move_timer.timeout.emit()

func has_anim(anim_name: String) -> bool:
	return self.target.has_anim(anim_name)
	
func play_anim(anim_name: String):
	self.target.play_anim(anim_name)
	
func set_orientation(orientation: Vector2):
	if current_orientation == orientation:
		return
	current_orientation = orientation
	if self.target:
		self.target.set_orientation(orientation)

	orientation = VarsService.round_orientation_with_bias(orientation)
	raycast.set_target_position(orientation * interaction_vector_length)
	
func set_mode(mode: ProxyMode):
	self.current_mode = mode
	match(self.current_mode):
		ProxyMode.GAMEPLAY:
			self.set_physics_process(true)
			self.set_process_unhandled_input(true)
			self._set_process_collisions(true)
			if self.target:
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
			
			
		

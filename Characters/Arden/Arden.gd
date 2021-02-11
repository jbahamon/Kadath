extends KinematicBody2D


const walk_speed = 120
const interaction_vector = Vector2(16, 8)


var input_vector = Vector2.ZERO
var velocity = Vector2.ZERO


onready var raycast: RayCast2D = $RayCast2D
onready var animation_tree: AnimationTree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")


func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		raycast.force_raycast_update()
		if raycast.is_colliding() and raycast.get_collider().has_method("trigger_interaction"):
			raycast.get_collider().trigger_interaction()
			
			

func _physics_process(_delta):
	var input_vector_changed = update_input_vector()
	
	if input_vector_changed:
		update_velocity()
		update_orientation()
		update_animation()
		
	move()

func move():
	velocity = move_and_slide(velocity)


func update_velocity():
	if input_vector != Vector2.ZERO:
		velocity = input_vector.normalized() * get_movement_speed()
	else:
		velocity = Vector2.ZERO


func update_input_vector():
	var old_input_vector = input_vector
	input_vector = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	return old_input_vector == input_vector
	
	
func get_movement_speed():
	return walk_speed


func update_animation():	
	if velocity == Vector2.ZERO:
		animation_state.travel("idle")
	else:
		animation_state.travel("walk")
		
		
func update_orientation():
	if velocity == Vector2.ZERO:
		return
		
	self.animation_tree["parameters/idle/blend_position"] = input_vector
	self.animation_tree["parameters/walk/blend_position"] = input_vector
	
	
	raycast.set_cast_to(Vector2(
			interaction_vector.x * input_vector.x, 
			interaction_vector.y * input_vector.y
	))

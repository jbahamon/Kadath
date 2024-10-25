extends NPCMovement

enum PathMode {
	LINEAR, 
	LOOP,
	BOUNCE
}

@export var speed = 100
@export var mode: PathMode = PathMode.LOOP

@export var starting_target_idx: int = 0

var initialized = false
var current_target_idx: int
var direction = Vector2.UP
var idx_direction = 1


# Note that we don't use most of the Path2D methods because
# they interpolate between vertexes, which is pretty bad for sharp turns
# common in NPC behavior
@export var path_2D_path: NodePath
var points: PackedVector2Array
var anim_name: String

func _ready():
	self.set_physics_process(false)
	var path = get_node(path_2D_path)
	var origin = path.global_position
	var curve: Curve2D = path.get_curve()

	self.points = range(curve.point_count).map(
		func(idx): return origin + curve.get_point_position(idx)
	)


func start():
	self.set_physics_process(true)
	if not self.initialized:
		self.parent.play_anim("walk")
		self.current_target_idx = self.starting_target_idx
		self.update_target()
		self.initialized = true
	else:
		self.parent.set_orientation(self.direction)
		self.parent.velocity = direction * speed
		
func stop():
	self.set_physics_process(false)
	self.parent.play_anim("idle")
		
func update_target():
	if current_target_idx >= self.points.size() or current_target_idx < 0:
		self.handle_endpoint()
		if self.mode == PathMode.LINEAR:
			return
	
	var start_position = self.parent.global_position
	var end_position = self.points[self.current_target_idx]
	
	self.direction = (end_position - start_position).normalized()
	self.parent.velocity = direction * speed
	self.parent.set_orientation(self.direction)
	
func _physics_process(delta):
	super._physics_process(delta)
	var displacement_squared = (delta * speed) * (delta * speed)
	var distance_to_target_squared = self.points[self.current_target_idx].distance_squared_to(self.parent.global_position)
	
	if displacement_squared < distance_to_target_squared:
		self.parent.move_and_slide()
	else:
		self.parent.move_and_slide()
		self.parent.global_position = self.points[self.current_target_idx]
		var remainder = (
			speed - self.points[self.current_target_idx].distance_to(self.parent.global_position) / delta
		)
		self.current_target_idx += self.idx_direction
		self.update_target()
		var original_velocity = parent.velocity
		self.parent.velocity = direction * remainder
		self.parent.move_and_slide()
		self.parent.velocity = original_velocity

	
func handle_endpoint():
	match self.mode:
		PathMode.LINEAR:
			self.set_physics_process(false)
			self.parent.velocity = Vector2.ZERO
			self.parent.play_anim("idle")
		PathMode.LOOP:
			self.current_target_idx = 0
		PathMode.BOUNCE:
			if self.idx_direction > 0:
				self.current_target_idx = self.points.size() - 2
			else:
				self.current_target_idx = 1
			
			self.idx_direction = -self.idx_direction

extends NPCMovement

enum PathMode {
	LINEAR, 
	LOOP,
	BOUNCE
}

@export var speed = 100
@export var mode: PathMode = PathMode.LINEAR

@export var starting_target_idx: int = 0

var initialized = false
var base_position: Vector2
var current_target_idx: int
var points: PackedVector2Array

var direction = 1
var tolerance =  1

func _ready():
	self.set_physics_process(false)
	self.points = []
	for child in self.get_children():
		self.points.append(child.position)

func start():
	self.set_physics_process(true)
	if not self.initialized:
		self.parent.play_anim("walk")
		self.current_target_idx = self.starting_target_idx
		self.update_movement()
		self.initialized = true
		
func stop():
	self.set_physics_process(false)
	self.parent.play_anim("idle")
	self.parent.velocity = Vector2.ZERO
		
func update_movement():
	if current_target_idx >= self.points.size() or current_target_idx < 0:
		self.handle_endpoint()
		if self.mode == PathMode.LINEAR:
			return
	
	var start_position = self.parent.position
	var end_position = self.points[self.current_target_idx]
	
	var current_direction = (end_position - start_position).normalized()
	self.parent.velocity = current_direction * self.speed
	self.parent.set_orientation(current_direction)
	
func _physics_process(delta):
	super._physics_process(delta)
	if (self.parent.position - self.points[self.current_target_idx]).length() < max(delta * self.speed, self.tolerance):
		self.current_target_idx += self.direction
	
		self.update_movement()
	
func handle_endpoint():
	match self.mode:
		PathMode.LINEAR:
			self.set_physics_process(false)
			self.parent.velocity = Vector2.ZERO
			self.parent.play_anim("idle")
		PathMode.LOOP:
			self.current_target_idx = 0
		PathMode.BOUNCE:
			if self.direction > 0:
				self.current_target_idx = self.points.size() - 2
			else:
				self.current_target_idx = 1
			
			self.direction = -self.direction

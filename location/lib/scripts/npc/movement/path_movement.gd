extends NPCMovement

enum PathMode {
	LINEAR, 
	LOOP,
	BOUNCE
}

export var speed = 100
export (PathMode) var mode: int = PathMode.LINEAR

export var starting_target_idx: int = 0

var initialized = false
var base_position: Vector2
var current_target_idx: int
var points: PoolVector2Array

var direction = 1
var tolerance =  1

func _ready():
	self.points = []
	for child in self.get_children():
		self.points.append(child.position)

	
func set_physics_process(value):
	if value and not self.initialized:
		self.current_target_idx = self.starting_target_idx
		self.update_movement()
	.set_physics_process(value)

func update_movement():
	
	
	if current_target_idx >= self.points.size() or current_target_idx < 0:
		self.handle_endpoint()
		if self.mode == PathMode.LINEAR:
			self.parent.velocity = Vector2.ZERO
			self.parent.play_anim("idle")
			return
	
	var start
	
	if not self.initialized:
		self.initialized = true
		start = self.parent.position
	else:
		start = self.points[self.current_target_idx - direction] 
	var end = self.points[self.current_target_idx]
	
	var current_direction = (end - start).normalized()
	self.parent.velocity = current_direction * self.speed
	self.parent.set_orientation(current_direction)
	
func _physics_process(delta):
	._physics_process(delta)
	
	if not self.initialized:
		self.parent.play_anim("walk")
		self.current_target_idx = self.starting_target_idx
		self.update_movement()
		
	if (self.parent.position - self.points[self.current_target_idx]).length() < max(delta * self.speed, self.tolerance):
		self.current_target_idx += self.direction
		self.update_movement()
	
func handle_endpoint():
	match self.mode:
		PathMode.LINEAR:
			self.set_physics_process(false)
		PathMode.LOOP:
			self.current_target_idx = 0
			self.update_movement()
		PathMode.BOUNCE:
			if self.direction > 0:
				self.current_target_idx = self.points.size() - 2
			else:
				self.current_target_idx = 1
			
			self.direction = -self.direction
			self.update_movement()
			

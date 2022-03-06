extends NPCMovement

export var period: float = 3.0

var time = 0

func _ready():
	time = randf() * period
	
func _process(delta):
	time += delta
	if time > period:
		choose_random_rotation()
		time = time - period
	
func choose_random_rotation():
	var facing = Vector2(1, 0)
	
	if randi() % 2 > 0:
		facing.x = -facing.x
		
	
	if randi() % 2 > 0:
		facing.y = facing.x
		facing.x = facing.y
		
	parent.facing = facing
	parent.update_facing()

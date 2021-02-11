extends BaseNPC

const NPCIdleState = preload("NPCIdleState.gd")
const NPCMoveState = preload("NPCMoveState.gd")

var states = {
	"idle": NPCIdleState.new(),
	"move": NPCMoveState.new()
}

var _state
var state_time = 0
var facing = Vector2.DOWN

onready var animation_tree: AnimationTree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")


func _ready():
	._ready()
	state_time = 0
	_state = states["idle"]
	_state.enter(self)


func _process(delta):
	state_time += delta
	_state._process(self, delta)


func _physics_process(delta):
	_state._physics_process(self, delta)


func rotate_facing(angle):
	facing = facing.rotated(angle)
	animation_tree["parameters/idle/blend_position"] = facing
	animation_tree["parameters/move/blend_position"] = facing


func change_state(state_name):
	_state.exit(self)
	_state = self.states[state_name]
	state_time = 0
	_state.enter(self)
	

func set_animation(animation_name):
	animation_state.travel(animation_name)
	

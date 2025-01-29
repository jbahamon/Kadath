extends Node

var Shaker = preload("res://utils/shaker.gd")

var DecayMode = Shaker.DecayMode
var layers: Dictionary

func initialize(init_layers: Dictionary):
	self.layers = init_layers

func exit():
	self.layers = {}

func get_layer(layer_id: String):
	return self.layers.get(layer_id)

func env_shake(duration: float, amplitude: Vector2, time_scale_factor: float):
	return self.shake(CameraService.get_camera(), duration, amplitude, time_scale_factor, Shaker.DecayMode.LINEAR)
	
func shake(object: Node, duration: float, amplitude: Vector2, time_scale_factor: float, decay_mode):
	var shaker = Shaker.new()
	object.add_child(shaker)
	
	shaker.start(duration, amplitude, time_scale_factor, decay_mode)
	return shaker

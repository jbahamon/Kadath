extends Node

var layers: Dictionary

func initialize(init_layers: Dictionary):
	self.layers = init_layers
	
func get_layer(layer_id: String):
	return self.layers.get(layer_id)

extends Area2D

@export var dialogue_name: String = ""
@onready var parent = get_parent()
@onready var shape = $CollisionShape2D

func enable():
	self.shape.disabled = false

func disable():
	self.shape.disabled = true
	
func get_dialogue_name():
	return self.dialogue_name if "dialogue_name" in self and self.dialogue_name != "" else self.parent.dialogue_name
	
	
func on_player_interaction(proxy: PlayerProxy):
	self.disable()
	var was_input_enabled = InputService.input_enabled
	proxy.set_mode(PlayerProxy.ProxyMode.CUTSCENE)
	InputService.input_enabled = false
	
	await DialogueService.open_dialogue(self.get_dialogue_name())
	
	InputService.input_enabled = was_input_enabled
	proxy.set_mode(PlayerProxy.ProxyMode.GAMEPLAY)
	self.enable()

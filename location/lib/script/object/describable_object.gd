extends InteractableObject

@export var dialogue_name: String = "test_message"
@export var interactable_collision_path: NodePath

@onready var interactable_collision = get_node(self.interactable_collision_path) 

func on_player_interaction(player_proxy: PlayerProxy):
	super.on_player_interaction(player_proxy)
	self.interactable_collision.set_disabled(true)
	
	var was_input_enabled = InputService.is_input_enabled()
	player_proxy.set_mode(PlayerProxy.ProxyMode.CUTSCENE)
	InputService.set_input_enabled(false)
	
	await DialogueService.open_dialogue(self.dialogue_name)
	
	InputService.set_input_enabled(was_input_enabled)
	player_proxy.set_mode(PlayerProxy.ProxyMode.GAMEPLAY)
	self.interactable_collision.set_disabled(false)
	
	

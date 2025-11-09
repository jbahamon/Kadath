extends Node

var PartyScene = preload("res://party/party.tscn")

var party: Party = null
var proxy: PlayerProxy = null
var battle_turn_indicator = null
var interaction_indicator = null

func initialize(init_proxy: PlayerProxy, init_interaction_indicator, init_battle_turn_indicator):
	self.interaction_indicator = init_interaction_indicator
	self.battle_turn_indicator = init_battle_turn_indicator

	self.party = PartyScene.instantiate()
	self.party.add_to_group("save")
	
	# Starting equipment for prologue
	self.party.inventory.set_item("002_potent_draught", 10)
	self.party.inventory.set_item("004_calming_balsam", 10)
	self.party.inventory.set_item("007_reanimation_scroll", 5)
	self.add_child(party)

	self.proxy = init_proxy
	self.proxy.set_mode(PlayerProxy.ProxyMode.NOT_THERE)
	
func exit():
	self.party.set_physics_process(false)
	self.party = null
	self.proxy = null
	
func bind_proxy():
	self.proxy.set_target(self.party)
	
func get_entity(entity_name: String):
	match entity_name:
		"CAMERA":
			return CameraService.get_camera()
		"PROXY":
			return self.proxy
		"ROOM":
			return EnvironmentService.current_room
		"WORLD":
			return EnvironmentService.get_world()
		"PARTY":
			return self.party
		_:
			return self.get_room_entity(entity_name)
			
func get_room_entity(entity_name: String):
	var room = EnvironmentService.current_room
	
	if room == null:
		return null
	
	
	var object = room.get_node_or_null("./" + entity_name)

	return object

func get_active_party_members():
	return self.party.get_active_members()

func on_exit_room():
	self.party.remove_from_room()
	
func on_enter_room():
	self.party.add_to_room()
	
func stop():
	self.party.queue_free()
	self.proxy.queue_free()

extends Node

var PartyScene = preload("res://party/party.tscn")

var party: Party = null
var proxy: PlayerProxy = null


func initialize(init_proxy: PlayerProxy):
	self.party = PartyScene.instantiate()
	self.party.add_to_group("save")
	
	# Starting equipment for prologue
	self.party.inventory.set_item("potion", 10)
	self.party.inventory.set_item("palingenesis_scroll", 40)
	self.add_child(party)

	self.proxy = init_proxy
	self.proxy.set_mode(PlayerProxy.ProxyMode.NOT_THERE)

func exit():
	self.party = null
	self.proxy = null
	
func bind_proxy():
	self.proxy.set_target(self.party)
	
func get_entity(entity_name: String):
	match entity_name:
		"CAMERA":
			return CameraService.get_camera()
		"PROXY":
			return self.get_proxy()
		"ROOM":
			return EnvironmentService.get_room()
		"WORLD":
			return EnvironmentService.get_world()
		"PARTY":
			return self.get_party()
		_:
			return self.get_room_entity(entity_name)
			
func get_room_entity(entity_name: String):
	var room = EnvironmentService.get_room()
	
	if room == null:
		return null
		
	var object = room.get_node_or_null("./" + entity_name)
	
	return object

func get_active_party_members():
	return self.party.get_active_members()

func get_party():
	return self.party

func get_proxy():
	return self.proxy

func on_exit_room():
	self.party.remove_from_room()
	
func on_enter_room():
	self.party.add_to_room()
	
func stop():
	self.party.queue_free()
	self.proxy.queue_free()

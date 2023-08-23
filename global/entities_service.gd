extends Node

var party: Party
var proxy: PlayerProxy

func initialize(init_proxy: PlayerProxy, init_party: Party):
	self.proxy = init_proxy
	self.party = init_party
	
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
	
	if object != null:
		return object
		
	object = self.party.get_node_or_null("./" + entity_name)
	return object

func get_active_party_members():
	return self.party.get_active_members()

func get_party():
	return self.party

func get_proxy():
	return self.proxy

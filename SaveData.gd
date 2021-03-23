class_name SaveData
const MAX_SAVE_FILES = 6
const FILENAME_FORMAT = "user://save_file_%d.dat"
var player_position: Vector2 = Vector2(0, 0)
var location_name: String = "CavernOfFlame"
var inventory: Array = [] # for simplicity, an array of [id,  n] pairs

func init_from_current_state():
	location_name = PlayerVars.location_name
	player_position = PlayerVars.player.position
	inventory = PlayerVars.inventory.get_ids_and_amounts()
		
func save_to_slot(slot_index):
	var filename = FILENAME_FORMAT % slot_index
	var file = File.new()
	file.open(filename, File.WRITE)
	file.store_var(self.player_position) 
	file.store_pascal_string(self.location_name)
	file.store_var(self.inventory) 
	file.close()


func init_from_slot(slot_index):
	var filename = FILENAME_FORMAT % slot_index
	var file = File.new()
	file.open(filename, File.READ)
	self.player_position = file.get_var() 
	self.location_name = file.get_pascal_string()
	self.inventory = file.get_var() 
	file.close()
	
	
static func get_file_previews():
	var save_filenames = []
	var file = File.new()
	for i in range(MAX_SAVE_FILES):
		var filename = FILENAME_FORMAT % i
		if file.file_exists(filename):
			save_filenames.push_back(filename)
		else:
			save_filenames.push_back(null)
	
	return save_filenames

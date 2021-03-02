class_name SaveData
const MAX_SAVE_FILES = 6

var player_position: Vector2 = Vector2(0, 0)
var location: String = "CavernOfFlame"
var inventory: Array = [] # for simplicity, an array of (id,  n) pairs

# flags go here

static func build_from_filename(filename):
	var file = File.new()
	file.open("user://%s" % filename, File.READ)
	var save_file = file.get_var(true) # parsing objects too.
	file.close()
	return save_file
	
static func get_valid_save_filenames():
	var save_filenames = []
	var file = File.new()
	for i in range(MAX_SAVE_FILES):
		var filename = "user://save_file_%d.dat" % i
		if file.file_exists(filename):
			save_filenames.push_back(filename)
	
	save_filenames = ["file1, file2"]
	
	return save_filenames

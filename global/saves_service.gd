extends Node
# Saves and loads savegame files
# Each node is responsible for finding itself in the save_game
# dict so saves don"t rely on the nodes" path or their source file

const MAX_SAVE_FILES = 6
const SAVE_FOLDER: String = "res://debug/save"
# TODO: Use project setting to save to res://debug vs user://

const SAVE_NAME_TEMPLATE = "save_file_%03d.tres"

func save(slot_index: int) -> void:
	# Passes a SaveGame resource to all nodes to save data from
	# and writes it to the disk
	var save_data := SaveData.new()
	save_data.game_version = ProjectSettings.get_setting("application/config/version")
	
	for node in get_tree().get_nodes_in_group("save"):
		node.save(save_data)

	var directory: DirAccess = DirAccess.open("res://")
	if not directory.dir_exists(SAVE_FOLDER):
		directory.make_dir_recursive(SAVE_FOLDER)

	var save_path = SAVE_FOLDER.path_join(SAVE_NAME_TEMPLATE % slot_index)
	
	var error: int = ResourceSaver.save(save_data, save_path)
	if error != OK:
		print("There was an issue writing the save %s to %s" % [slot_index, save_path])

	
func load_game_data(slot_index: int) -> void:
	# Reads a saved game from the disk and delegates loading
	# to the individual nodes to load
	var save_file_path: String = SAVE_FOLDER.path_join(SAVE_NAME_TEMPLATE % slot_index)
	
	if not FileAccess.file_exists(save_file_path):
		print("Save file %s doesn't exist" % save_file_path)
		return

	var save_game: Resource = load(save_file_path)
	for node in get_tree().get_nodes_in_group("save"):
		node.load_game_data(save_game)

	
func get_file_previews() -> Array:
	var save_filenames = []
	
	for i in range(MAX_SAVE_FILES):
		
		var filename = SAVE_FOLDER.path_join(SAVE_NAME_TEMPLATE % i)
		if FileAccess.file_exists(filename):
			save_filenames.push_back({
				"index": i,
				"file": filename
			})
		else:
			save_filenames.push_back({
				"index": i,
				"file": null
			})
	
	return save_filenames

func has_file_with_data() -> bool:
	return get_file_previews().any(func (it): return it != null)

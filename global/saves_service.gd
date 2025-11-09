extends Node
# Saves and loads savegame files
# Each node is responsible for finding itself in the save_game
# dict so saves don"t rely on the nodes" path or their source file

const MAX_SAVE_FILES = 6
const SAVE_FOLDER: String = "res://debug/save"
# TODO: Use project setting to save to res://debug vs user://

const PREVIEWS_FILE_NAME = "save_previews.tres"
const SAVE_NAME_TEMPLATE = "save_file_%03d.tres"

enum SaveAccessMode {SAVE, LOAD}

var previews: SavePreviews
var total_playtime: int
var load_time: int
var loaded_slot = -1

func _init() -> void:
	var directory: DirAccess = DirAccess.open("res://")
	if not directory.dir_exists(SAVE_FOLDER):
		directory.make_dir_recursive(SAVE_FOLDER)

func save_game_data(save_spot: String, slot_index: int) -> void:
	if slot_index not in self.previews.data:
		self.previews.data[slot_index] = {}
	
	self.previews.data[slot_index]["party"] = EntitiesService.party.get_active_members().map(
		func(party_member: PartyMember):
			return {
				"id": party_member.id,
				"name": party_member.display_name,
				"level": party_member.level,
			}
	)
	
	self.previews.data[slot_index]["save_spot_name"] = save_spot
	self.previews.data[slot_index]["save_datetime"] = Time.get_datetime_string_from_system(false, true)	
	self.previews.data[slot_index]["total_playtime"] = self.total_playtime + Time.get_ticks_msec() - self.load_time
	
	var previews_path = SAVE_FOLDER.path_join(PREVIEWS_FILE_NAME)
	var error: int = ResourceSaver.save(self.previews, previews_path)
	if error != OK:
		print("There was an issue writing previews to %s" % previews_path)

	# Passes a SaveGame resource to all nodes to save data from
	# and writes it to the disk
	var save_data := SaveData.new()
	save_data.game_version = ProjectSettings.get_setting("application/config/version")
	
	for node in get_tree().get_nodes_in_group("save"):
		node.save_game_data(save_data)
	
	self.loaded_slot = slot_index

	var save_path = SAVE_FOLDER.path_join(SAVE_NAME_TEMPLATE % slot_index)
	
	error = ResourceSaver.save(save_data, save_path)
	if error != OK:
		print("There was an issue writing the save %s to %s" % [slot_index, save_path])

	
func load_game_data(slot_index: int) -> void:
	# Reads a saved game from the disk and delegates loading
	# to the individual nodes to load
	var save_file_path: String = SAVE_FOLDER.path_join(SAVE_NAME_TEMPLATE % slot_index)
	
	load_time = Time.get_ticks_msec()
	total_playtime = previews.data[slot_index]["total_playtime"]

	if not FileAccess.file_exists(save_file_path):
		print("Save file %s doesn't exist" % save_file_path)
		return

	var save_game: Resource = load(save_file_path)
	for node in get_tree().get_nodes_in_group("save"):
		node.load_game_data(save_game)
	
func get_file_previews(force_load=false) -> Array:
	if force_load:
		load_save_previews()
		
	var save_filenames = []
	
	for i in range(MAX_SAVE_FILES):
		
		var filename = SAVE_FOLDER.path_join(SAVE_NAME_TEMPLATE % i)
		if FileAccess.file_exists(filename):
			save_filenames.push_back({
				"index": i,
				"file": filename,
				"preview": previews.data.get(i, {
					"total_playtime": 0,
					"save_datetime": Time.get_datetime_string_from_unix_time(0, true),
					"save_spot_name": "????",
				})
			})
		else:
			save_filenames.push_back({
				"index": i,
				"file": null
			})
	return save_filenames

func load_save_previews():
	var filename = SAVE_FOLDER.path_join(PREVIEWS_FILE_NAME)
	if FileAccess.file_exists(filename):
		self.previews = load(filename)
	else:
		self.previews = SavePreviews.new()

func has_file_with_data() -> bool:
	return get_file_previews().any(func (it): return it["file"] != null)

extends Node

signal scene_loaded

var current_loading_path = ""

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	self.set_process(false)
	
func load_scene(path):
	self.current_loading_path = path
	ResourceLoader.load_threaded_request(path)
	set_process(true)

func _process(_delta):
	match ResourceLoader.load_threaded_get_status(self.current_loading_path):
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			set_process(false)
			self.scene_loaded.emit()
			return
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			print("resouce invalid: %s" % self.current_loading_path)
			get_tree().quit()
			return
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			print("load failed: %s" % self.current_loading_path)
			get_tree().quit()
			return
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			return

func switch_scene():
	var resource = ResourceLoader.load_threaded_get(self.current_loading_path)
	set_process(false)
	self.current_loading_path = ""
	var current_scene = get_tree().current_scene
	if "exit" in current_scene:
		current_scene.exit()
	get_tree().change_scene_to_packed(resource)

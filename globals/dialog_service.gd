extends Node

var dialog_box
var narration_layer
var current_dialog: DialogueResource

func initialize(init_dialog_box, init_narration_layer):
	self.dialog_box = init_dialog_box
	self.narration_layer = init_narration_layer

func load_location_dialogs(location: Location):
	self.current_dialog = location.story

func open_dialog(dialog_id: String, source) -> void:
	if source != null:
		dialog_box.set_default_source(source.name)
	else:
		dialog_box.set_default_source("None")
	var pool = []
	
	# Branching dialog shall be implemented as needed
	
	while dialog_id:
		var dialog_line = await self.current_dialog.get_next_dialogue_line(dialog_id)
		var text = dialog_line.text.format(VarsService.strings)
		pool.append({
			"text": text,
			"character": dialog_line.character
		})
		dialog_id = dialog_line.next_id

	dialog_box.queue_texts(pool)
	await dialog_box.dialog_closed
			
func narrate(dialog_id: String, duration: float) -> void:
	var dialog_line = await self.current_dialog.get_next_dialogue_line(dialog_id)
	
	if not dialog_line:
		return

	await narration_layer.narrate(dialog_line.text.format(VarsService.strings), duration)
	

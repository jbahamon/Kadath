extends Node

var dialog
var narration_layer
var current_dialog: DialogueResource

func initialize(init_dialog, init_narration_layer):
	self.dialog = init_dialog
	self.narration_layer = init_narration_layer

func load_location_dialogs(location: Location):
	self.current_dialog = location.story

func open_dialog(dialog_id: String, _source) -> void:
	var dialog_lines = []
	
	# Branching dialog shall be implemented as needed
	
	while dialog_id:
		var dialog_line = await self.current_dialog.get_next_dialogue_line(dialog_id)
		if dialog_line == null:
			break
		
		var strings = VarsService.strings
		var text = dialog_line.text.format(strings)
		dialog_lines.append({
			"text": text,
			"source": dialog_line.character
		})
		dialog_id = dialog_line.next_id

	dialog.queue_dialog_lines(dialog_lines)
	await dialog.closed
	
			
func narrate(dialog_id: String, duration: float) -> void:
	var dialog_line = await self.current_dialog.get_next_dialogue_line(dialog_id)
	
	if not dialog_line:
		return

	await narration_layer.narrate(dialog_line.text.format(VarsService.strings), duration)
	

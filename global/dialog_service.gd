extends Node

var dialog
var narration_layer
var current_dialog: DialogueResource
var current_responses: Array = []

func initialize(init_dialog, init_narration_layer):
	self.dialog = init_dialog
	self.narration_layer = init_narration_layer

func load_location_dialogs(location: Location):
	self.current_dialog = location.story

func add_response(response):
	self.current_responses.append(response)
	
func open_dialog(dialog_id: String) -> Array:
	self.current_responses = []
	var dialog_lines = []
	
	# Branching dialog shall be implemented as needed
	
	while dialog_id:
		var dialog_line: DialogueLine = await self.current_dialog.get_next_dialogue_line(dialog_id)
		if dialog_line == null:
			break
		
		var strings = VarsService.strings
		var text = dialog_line.text.format(strings) # this might not be needed later
		
		if dialog_line.responses.size() > 0:
			for response in dialog_line.responses:
				dialog_line.text = dialog_line.text.format(VarsService.strings)

			dialog_lines.append({
				"responses": dialog_line.responses,
				"text": text
			})
			
			dialog.queue_dialog_lines(dialog_lines)
			var response: DialogueResponse = await dialog.response_chosen
			dialog_lines = []
			dialog_id = response.next_id
		else:
			dialog_lines.append({
				"text": text,
				"source": dialog_line.character
			})
			
			dialog_id = dialog_line.next_id
		
	if dialog_lines.size() > 0:
		dialog.queue_dialog_lines(dialog_lines)
		await dialog.closed
		return self.current_responses
	else:
		dialog.close_dialog()
		return self.current_responses
	
			
func narrate(dialog_id: String, duration: float) -> void:
	var dialog_line = await self.current_dialog.get_next_dialogue_line(dialog_id)
	
	if not dialog_line:
		return

	await narration_layer.narrate(dialog_line.text.format(VarsService.strings), duration)
	

extends Node

var dialogue_box
var narration_layer
var current_dialogue: DialogueResource
var current_responses: Array = []

func initialize(init_dialogue_box, init_narration_layer):
	self.dialogue_box = init_dialogue_box
	self.narration_layer = init_narration_layer

func exit():
	#self.dialogue = null
	self.narration_layer = null
	self.current_dialogue = null
	self.current_responses = []
	
func load_location_dialogues(location: Location):
	self.current_dialogue = location.story
	
func add_response(response):
	self.current_responses.append(response)
	
func open_dialogue(dialogue_id: String) -> Array:
	self.current_responses = []
	var dialogue_lines = []
	
	# Branching dialogue shall be implemented as needed
	
	while dialogue_id:
		var dialogue_line: DialogueLine = await self.current_dialogue.get_next_dialogue_line(dialogue_id)
		if dialogue_line == null:
			break
		var strings = VarsService.strings
		var text = dialogue_line.text.format(strings) # this might not be needed later
		
		if dialogue_line.responses.size() > 0:
			for response in dialogue_line.responses:
				dialogue_line.text = dialogue_line.text.format(VarsService.strings)

			dialogue_lines.append({
				"responses": dialogue_line.responses,
				"text": text
			})
			
			
			dialogue_box.queue_dialogue_lines(dialogue_lines)
			
			# Note that this doesn't handle skipped cutscenes. We establish that 
			# cutscenes involving user input should be unskippable. If needed, break up the 
			# cutscene as needed to limit the unskippable part.
			var response: DialogueResponse = await dialogue_box.response_chosen
			
			dialogue_lines = []
			dialogue_id = response.next_id
		else:
			dialogue_lines.append({
				"text": text,
				"source": dialogue_line.character
			})
			
			dialogue_id = dialogue_line.next_id
		
	if dialogue_lines.size() > 0:
		dialogue_box.queue_dialogue_lines(dialogue_lines)
		await dialogue_box.closed
		return self.current_responses
	else:
		dialogue_box.close_dialogue_box()
		return self.current_responses
	

func pause_dialogue():
	dialogue_box.pause()

func resume_dialogue():
	dialogue_box.resume()

func skip_dialogue():
	dialogue_box.skip()

func narrate(dialogue_id: String) -> void:
	var dialogue_line = await self.current_dialogue.get_next_dialogue_line(dialogue_id)
	
	if not dialogue_line:
		return

	await narration_layer.narrate(dialogue_line.text.format(VarsService.strings))

func tween_text(text_container, text: String):
	text_container.set_text(text)
	var tween = self.get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	var time = text_container.get_total_character_count() / SettingsService.text_speed
	tween.tween_method(text_container.set_visible_ratio, 0.0, 1.0, time)
	tween.play()
	return tween
	
func skip_narration():
	narration_layer.skip()

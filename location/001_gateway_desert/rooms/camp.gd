extends LocationRoom
var TextInputPrompt = load('res://ui/02_molecules/text_input_prompt/text_input_prompt.tscn')

signal name_chosen
	
func choose_alex_name():
	var popup = TextInputPrompt.instantiate()
	popup.set_default('Alex')
	popup.closed.connect(self.on_name_chosen)
	UIService.show_popup(popup)
	await self.name_chosen

func on_name_chosen(name: String) -> void:
	VarsService.set_string('alex_name', name)
	emit_signal('name_chosen')

func enable_alex_tent():
	$Tent5.visible = true
	$Tent5/CollisionShape2D.disabled = false

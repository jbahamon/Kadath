extends LocationRoom
var TextInputPrompt = load('res://ui/02_molecules/text_input_prompt/text_input_prompt.tscn')

signal name_chosen
	
func choose_arden_name():
	var popup = TextInputPrompt.instantiate()
	popup.set_default('Arden')
	popup.closed.connect(self.on_name_chosen)
	UIService.show_popup(popup)
	await self.name_chosen

func on_name_chosen(name: String) -> void:
	VarsService.set_string('arden_name', name)
	emit_signal('name_chosen')

func enable_arden_tent():
	$Tent5.visible = true
	$Tent5/CollisionShape2D.disabled = false

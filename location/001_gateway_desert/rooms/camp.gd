extends LocationRoom
var TextInputPrompt = load('res://ui/02_molecules/text_input_prompt/text_input_prompt.tscn')

signal name_chosen

func on_enter():
	var menu = self.get_local_scene().menu
	
func choose_arden_name():
	var popup = TextInputPrompt.instance()
	popup.set_default('Arden')
	popup.connect("closed", self, "on_name_chosen")
	self.get_local_scene().show_popup(popup)
	yield(self, 'name_chosen')

func on_name_chosen(name: String) -> void:
	PlayerVars.set_string('arden_name', name)
	emit_signal('name_chosen')

func enable_arden_tent():
	$Tent5.visible = true
	$Tent5/CollisionShape2D.disabled = false

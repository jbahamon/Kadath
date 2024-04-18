extends PopupPanel
signal closed(text)

@onready var line_edit: LineEdit = $VBoxContainer/LineEdit
@onready var button: Button = $VBoxContainer/Button

var default_text

func _ready():
	if default_text != null:
		line_edit.text = default_text
		line_edit.caret_column = line_edit.text.length()
	update_confirm_button()
		
func _on_LineEdit_text_changed(new_text: String):
	update_confirm_button()

func set_default(default_text: String):
	self.default_text = default_text
	if line_edit != null:
		line_edit.text = default_text

func update_confirm_button():
	self.button.disabled = line_edit.text.strip_edges().length() == 0
	
func on_text_entered(text: String):
	close()
	
func close():
	var text = line_edit.text
	if text.strip_edges().length() > 0:
		self.hide()
		self.closed.emit(text.strip_edges())
		self.queue_free()

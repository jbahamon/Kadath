extends CanvasLayer

var CreditsEntry = preload("res://ui/02_molecules/credits_entry/credits_entry.tscn")
const SCROLL_STEP = 50

@onready var containers = {
	"graphics": $MarginContainer/ScrollContainer/VBox/Graphics,
	"sounds": $MarginContainer/ScrollContainer/VBox/Sounds,
	"code": $MarginContainer/ScrollContainer/VBox/Code,
	"other": $MarginContainer/ScrollContainer/VBox/Other
}

@onready var scroll = $MarginContainer/ScrollContainer

func _ready():
	var items = self.load_items()
	
	for item in items:
		var entry = CreditsEntry.instantiate()
		entry.set_item(item)
		containers[item.category].add_child(entry)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed :
		if event.is_action_pressed("ui_down"):
			scroll.set_v_scroll(scroll.get_v_scroll() + SCROLL_STEP)
		elif event.is_action_pressed("ui_up"):
			scroll.set_v_scroll(scroll.get_v_scroll() - SCROLL_STEP)
		

func load_items() -> Array:
	var file: FileAccess = FileAccess.open(VarsService.CREDITS_FILE, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

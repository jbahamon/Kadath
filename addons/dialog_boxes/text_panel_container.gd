@tool
extends PanelContainer

var _margin_container: MarginContainer
var _outline_margin_container: MarginContainer


func _ready():
	_margin_container = MarginContainer.new()
	_margin_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_margin_container.size_flags_vertical = SIZE_EXPAND_FILL
	_margin_container.clip_contents = true
	
	_outline_margin_container = MarginContainer.new()
	_outline_margin_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_outline_margin_container.size_flags_vertical = SIZE_EXPAND_FILL
	_outline_margin_container.clip_contents = false
	self.add_child(_margin_container)
	_margin_container.add_child(_outline_margin_container)
	_outline_margin_container.add_child(self.get_content())
	self.update_outline_margin()
	
func get_content():
	pass

func get_outline_size():
	return 0

func set_padding(new_padding: float):
	_margin_container.set("custom_constants/offset_top", new_padding)
	_margin_container.set("custom_constants/offset_bottom", new_padding)
	_margin_container.set("custom_constants/offset_left", new_padding)
	_margin_container.set("custom_constants/offset_right", new_padding)
	

func update_outline_margin():
	if _outline_margin_container == null:
		return
	var max_outline = get_outline_size()
	_outline_margin_container.set("custom_constants/offset_top", max_outline)
	_outline_margin_container.set("custom_constants/offset_bottom", max_outline)
	_outline_margin_container.set("custom_constants/offset_left", max_outline)
	_outline_margin_container.set("custom_constants/offset_right", max_outline)


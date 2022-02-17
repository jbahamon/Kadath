tool
extends PanelContainer

var _margin_container: MarginContainer
var _outline_margin_container: MarginContainer

func _init():
	_margin_container = MarginContainer.new()
	_margin_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_margin_container.size_flags_vertical = SIZE_EXPAND_FILL
	_margin_container.rect_clip_content = true
	
	_outline_margin_container = MarginContainer.new()
	_outline_margin_container.size_flags_horizontal = SIZE_EXPAND_FILL
	_outline_margin_container.size_flags_vertical = SIZE_EXPAND_FILL
	_outline_margin_container.rect_clip_content = false

func _ready():
	self.add_child(_margin_container)
	_margin_container.add_child(_outline_margin_container)
	_outline_margin_container.add_child(self.get_content())
	self.update_outline_margin()
	
func get_content():
	pass

func get_outline_size():
	return 0

func set_padding(new_padding: float):
	_margin_container.set("custom_constants/margin_top", new_padding)
	_margin_container.set("custom_constants/margin_bottom", new_padding)
	_margin_container.set("custom_constants/margin_left", new_padding)
	_margin_container.set("custom_constants/margin_right", new_padding)
	

func update_outline_margin():
	var max_outline = get_outline_size()
	_outline_margin_container.set("custom_constants/margin_top", max_outline)
	_outline_margin_container.set("custom_constants/margin_bottom", max_outline)
	_outline_margin_container.set("custom_constants/margin_left", max_outline)
	_outline_margin_container.set("custom_constants/margin_right", max_outline)


@tool
extends "./text_panel_container.gd"

signal transition_finished
signal text_shown

var AutoScroller = preload("./autoscroller.gd")
var _text_label: RichTextLabel

var _scroller

@onready var _text_tween = get_tree().create_tween()

func _init():
	_text_label = RichTextLabel.new()
	_text_label.clip_contents = false
	_scroller = AutoScroller.new()
	_scroller.initialize(_text_label)
	
	self.clip_contents = true

func _ready():
	self._text_tween.stop()
	self.size_flags_vertical = SIZE_EXPAND_FILL
	
func get_content():
	return _text_label
	
func set_text_property(property_name, value):
	_text_label.set(property_name, value)
	self.update_outline_margin()
	
func add_theme_font_override(name, value):
	super.add_theme_font_override(name, value)
	_text_label.add_theme_font_override(name, value)
	self.update_outline_margin()

func get_max_outline():
	var max_outline = 0
	var normal = _text_label.get_font("normal_font")
	var bold = _text_label.get_font("bold_font")
	var italics = _text_label.get_font("italics_font")
	var bold_italics = _text_label.get_font("bold_italics_font")
	var mono  = _text_label.get_font("mono_font")
	
	if normal.has_outline() and "outline_size" in normal:
		max_outline = max(max_outline, normal.outline_size)

	if bold.has_outline() and "outline_size" in bold:
		max_outline = max(max_outline, bold.outline_size)

	if italics.has_outline() and "outline_size" in italics:
		max_outline = max(max_outline, italics.outline_size)

	if bold_italics.has_outline() and "outline_size" in bold_italics:
		max_outline = max(max_outline, bold_italics.outline_size)
		
	if mono.has_outline() and "outline_size" in mono:
		max_outline = max(max_outline, mono.outline_size)

	return max_outline

func wait_for_label_resizing():
	if _text_label.size == Vector2.ZERO:
		await _text_label.resized
	else:
		return null

func on_text_shown():
	emit_signal("text_shown")

func on_transition_finished():
	emit_signal("transition_finished")

func reset_playback():
	_text_tween.stop()
	
func start_playback(text: String, speed: float):
	_text_label.visible_characters = 0
	_text_label.scroll_to_line(0)
	
	if _text_label.bbcode_enabled:
		_text_label.text = text
	else:
		_text_label.text = text
	
	var length = _text_label.text.length()
	var time = length/speed

	_text_tween.interpolate_property(_text_label, "percent_visible",
		0.0, 1.0, time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)

	_scroller.reset()

	_text_tween.interpolate_method(
		_scroller, "update_scroll", 0.0, 1.0, time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	
	_text_tween.start()

func set_velocity(factor: float):
	_text_tween.playback_speed = factor
	pass

func clear():
	_text_label.text = ""
	_text_label.text = ""
	

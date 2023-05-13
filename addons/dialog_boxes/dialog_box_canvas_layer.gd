@tool
extends CanvasLayer
var SourcePanelContainer = preload("./source_panel_container.gd")
var DialogPanelContainer = preload("./dialog_panel_container.gd")

signal on_state(new_state)
signal dialog_closed

enum DialogPosition { TOP, BOTTOM }
enum DialogState { HIDDEN, TRANSITION_IN, ADVANCING, WAITING_FOR_INPUT, TRANSITION_OUT }
enum TransitionMode { NONE, UNROLL, FADE }

const ANIMATION_DISPLAY_TEXT = "display_text"

# Behavior
@export var block_input: bool = true
@export var transition: TransitionMode = TransitionMode.NONE
@export var transition_time_ms: float = 20.0

# Sizing
@export var height_percent: float = 0.2 
@export var margin: int = 0 : set = set_margin
@export var padding: int = 0 : set = set_padding
@export var separation: int = 1 : set = set_separation

# Positioning
@export var positioning: DialogPosition = DialogPosition.BOTTOM : set = set_positioning

# Box styling
@export var advance_indicator_texture: Texture2D
@export var show_scroll: bool = false : set = set_show_scroll
@export var source_stylebox: StyleBox : set = set_source_stylebox
@export var dialog_stylebox: StyleBox : set = set_dialog_stylebox
@export var theme: Theme : set = set_theme

# Text speed
@export var text_speed: float = 9.0
@export var speedup_factor: float = 2.0

# Text styling

@export var normal_font: Font : set = set_normal_font
@export var mono_font: Font : set = set_mono_font
@export var bold_font: Font : set = set_bold_font
@export var italics_font: Font : set = set_italics_font
@export var bold_italics_font: Font : set = set_bold_font
@export var meta_underlined: bool = true : set = set_meta_underlined
@export var tab_size: int = 4 : set = set_tab_size
@export var custom_effects: Array = [] : set = set_custom_effects
@export var bbcode_enabled: bool = false : set = set_bbcode_enabled

@onready var _transition_tween: Tween = get_tree().create_tween()

# UI Components
var _vbox: VBoxContainer

var _source_container: Container
var _dialog_container: Container

var _scroller
var _advance_indicator: TextureRect
var current_state = DialogState.HIDDEN
var text_queue: PackedStringArray = PackedStringArray()
var default_source: String = '????'

func _init():
	_vbox = VBoxContainer.new()
	_vbox.name = "dialog_vbox"
	_vbox.visible = false
	
	_source_container = SourcePanelContainer.new()
	_source_container.name = "source_panel"
	_source_container.theme = theme
	
	_vbox.add_child(_source_container)
	
	_dialog_container = DialogPanelContainer.new()
	_dialog_container.name ="dialog_panel"
	_dialog_container.theme = theme
	
	_vbox.add_child(_dialog_container)

	_advance_indicator = TextureRect.new()
	_advance_indicator.visible = false
	
	self.add_child(_vbox)
	self.add_child(_advance_indicator)
	
func _ready():
	self._transition_tween.stop()
	
	set_process_unhandled_input(false)
		
	# We set the texture before positioning because we need to measure it.
	_advance_indicator.texture = advance_indicator_texture
	self.set_positioning(DialogPosition.BOTTOM)
	
	self.init_panels()
	
	_dialog_container.update_outline_margin()
	_transition_tween.connect("loop_finished", Callable(self,"on_transition_finished"))
	_dialog_container.connect("text_shown", Callable(self,"on_text_shown"))
	

func _unhandled_input(event):
	match current_state:
		DialogState.ADVANCING:
			if event.is_action_pressed("ui_accept"):
				_dialog_container.set_velocity(speedup_factor)
			elif event.is_action_released("ui_accept"):
				_dialog_container.set_velocity(1.0)
		DialogState.WAITING_FOR_INPUT:
			if event.is_action_pressed("ui_accept"):
				if text_queue.is_empty():
					change_state(DialogState.TRANSITION_OUT)
				else:
					change_state(DialogState.ADVANCING)
				
	if block_input:
		get_viewport().set_input_as_handled()

func set_default_source(source: String):
	self.default_source = source
	
func on_text_shown():
	if current_state == DialogState.ADVANCING:
		change_state(DialogState.WAITING_FOR_INPUT)

func on_transition_finished():
	if current_state == DialogState.TRANSITION_IN:
		change_state(DialogState.ADVANCING)
	elif current_state == DialogState.TRANSITION_OUT:
		change_state(DialogState.HIDDEN)

func change_state(new_state: int):
	if new_state == current_state:
		return
		
	match new_state:
		DialogState.HIDDEN:
			set_process_unhandled_input(false)
			_vbox.visible = false
		DialogState.TRANSITION_IN:
			transition_in()
		DialogState.ADVANCING:
			if _advance_indicator != null:
				_advance_indicator.visible = false
			
			_dialog_container.reset_playback()
			
			set_process_unhandled_input(true)
			
			if text_queue.is_empty():
				# We let the state last for at least a single frame.
				change_state(DialogState.TRANSITION_OUT)
			else:
				# We have to wait until the label is inflated.
				await _dialog_container.wait_for_label_resizing()
				dequeue_text()
		DialogState.WAITING_FOR_INPUT:
			if _advance_indicator.texture != null:
				# TODO why is this needed
				# update_advance_indicator_positioning()
				_advance_indicator.visible = true
			set_process_unhandled_input(true)
		DialogState.TRANSITION_OUT:
			if _advance_indicator != null:
				_advance_indicator.visible = false
			transition_out()
			
	current_state = new_state
	
	if new_state == DialogState.HIDDEN:
		emit_signal("dialog_closed")
	emit_signal("on_state", new_state)


func transition_in():
	# change to DialogPanelContainer.transition_in()
	match transition:
		TransitionMode.NONE:
			await get_tree().process_frame 
			change_state(DialogState.ADVANCING)
		TransitionMode.FADE:
			
			_transition_tween.interpolate_property(
				_dialog_container, "modulate",
				Color(1, 1, 1, 0), Color(1, 1, 1, 1), transition_time_ms/1000.0,
				Tween.TRANS_LINEAR, Tween.EASE_IN
			)
			_transition_tween.start()
		TransitionMode.UNROLL:
			_dialog_container.pivot_offset = _dialog_container.size/2.0
			_transition_tween.interpolate_property(
				_dialog_container, "scale",
				Vector2(1, 0), Vector2(1, 1), transition_time_ms/1000.0,
				Tween.TRANS_LINEAR, Tween.EASE_IN
			)
			_transition_tween.start()
	
	await get_tree().process_frame
	_vbox.visible = true
	
func transition_out():
	_dialog_container.clear()
	match transition:
		TransitionMode.NONE:
			await get_tree().idle_frame
			change_state(DialogState.HIDDEN)
		TransitionMode.FADE:
			_transition_tween.interpolate_property(
				_dialog_container, "modulate",
				Color(1, 1, 1, 1), Color(1, 1, 1, 0), transition_time_ms/1000.0,
				Tween.TRANS_LINEAR, Tween.EASE_IN
			)
		TransitionMode.UNROLL:
			_dialog_container.pivot_offset = _dialog_container.size/2.0
			_transition_tween.interpolate_property(
				_dialog_container, "scale",
				Vector2(1, 1), Vector2(1, 0), transition_time_ms/1000.0,
				Tween.TRANS_LINEAR, Tween.EASE_IN
			)
			_transition_tween.start()

	
func queue_texts(texts: PackedStringArray):
	text_queue.append_array(texts)
	match current_state:
		DialogState.HIDDEN:
			change_state(DialogState.TRANSITION_IN)
			
func dequeue_text():
	if text_queue.is_empty():
		return
	
	var new_text: String = text_queue[0]
	text_queue.remove_at(0)
	
	var source = self.default_source
	var text = new_text
	var split = new_text.split("\n", false, 1)
	
	
	if split.size() > 1 and split[0].begins_with("[") and split[0].ends_with("]"):
		split[0] = split[0].substr(1, split[0].length() - 2)
		source = split[0].format(VarsService.strings)
		text = split[1]
		
	if source == "None":
		source = null
		
	if source != null:
		_source_container.set_text(source)
		_source_container.visible = true
	else:
		_source_container.visible = false
	_dialog_container.start_playback(text, text_speed)

func set_margin(new_margin: int):
	margin = new_margin
	_vbox.offset_top = new_margin
	_vbox.offset_bottom = new_margin
	_vbox.offset_left = new_margin
	_vbox.offset_right = new_margin

func set_padding(new_value: int):
	padding = new_value
	_source_container.set_padding(new_value)
	_dialog_container.set_padding(new_value)

func set_separation(new_value: int):
	separation = new_value
	_vbox.add_theme_constant_override("separation", new_value)


func update_vbox_positioning(new_positioning, height_percent, margin):
	match new_positioning:
		DialogPosition.BOTTOM:
			_vbox.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE, Control.PRESET_MODE_MINSIZE, margin)
			_vbox.set_anchor_and_offset(SIDE_TOP, 1.0 - height_percent, margin)
			_vbox.grow_vertical = Control.GROW_DIRECTION_BEGIN
			_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		DialogPosition.TOP:
			_vbox.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE, Control.PRESET_MODE_MINSIZE, margin)
			_vbox.set_anchor_and_offset(SIDE_BOTTOM, height_percent, margin)
			_vbox.grow_vertical = Control.GROW_DIRECTION_END
			_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_: return
	
func update_advance_indicator_positioning():
	if _advance_indicator.texture == null:
		return
		
	_advance_indicator.position = _dialog_container.position + _dialog_container.size + \
			Vector2(_dialog_container.offset_right - _advance_indicator.texture.get_width(),
					_dialog_container.offset_bottom - _advance_indicator.texture.get_height())

func init_panels():
	_vbox.theme = theme
	_vbox.add_theme_constant_override("separation", self.separation)
	
	_dialog_container.set_text_property("bbcode_enabled", bbcode_enabled)
	_dialog_container.set_text_property("meta_underlined", meta_underlined)
	_dialog_container.set_text_property("tab_size", tab_size)
	_dialog_container.set_text_property("scroll_active", show_scroll)
	_dialog_container.set_text_property("custom_effects", custom_effects)
	
	
	
func set_meta_underlined(new_value: bool):
	meta_underlined = new_value
	_dialog_container.set_text_property("meta_underlined", new_value)


func set_tab_size(new_value: int):
	tab_size = new_value
	_dialog_container.set_text_property("tab_size", new_value)


func set_show_scroll(new_value: bool):
	show_scroll = new_value
	_dialog_container.set_text_property("scroll_active", new_value)


func set_custom_effects(new_value: Array):
	custom_effects = new_value
	_dialog_container.set_text_property("custom_effects", new_value)


func set_bbcode_enabled(new_value: bool):
	bbcode_enabled = new_value
	_dialog_container.set_text_property("bbcode_enabled", new_value)


func set_positioning(new_positioning: int):
	if _vbox != null:
		self.update_vbox_positioning(new_positioning, height_percent, margin)
		# update_source_positioning()
		self.update_advance_indicator_positioning()
	positioning = new_positioning


func set_normal_font(new_value: Font):
	normal_font = new_value
	_source_container.add_theme_font_override("normal", new_value)
	_dialog_container.add_theme_font_override("normal", new_value)

func set_bold_font(new_value: Font):
	bold_font = new_value
	_source_container.add_theme_font_override("bold", new_value)
	_dialog_container.add_theme_font_override("bold", new_value)

func set_italics_font(new_value: Font):
	italics_font = new_value
	_source_container.add_theme_font_override("italics", new_value)
	_dialog_container.add_theme_font_override("italics", new_value)

func set_bold_italics_font(new_value: Font):
	bold_italics_font = new_value
	_source_container.add_theme_font_override("bold_italics", new_value)
	_dialog_container.add_theme_font_override("bold_italics", new_value)
	
func set_mono_font(new_value: Font):
	mono_font = new_value
	_source_container.add_theme_font_override("mono", new_value)
	_dialog_container.add_theme_font_override("mono", new_value)
	
func set_source_stylebox(new_value: StyleBox):
	source_stylebox = new_value
	_source_container.add_theme_stylebox_override("panel", new_value)

func set_dialog_stylebox(new_value: StyleBox):
	dialog_stylebox = new_value
	_dialog_container.add_theme_stylebox_override("panel", new_value)

	
func set_theme(new_value: Theme):
	theme = new_value
	_source_container.theme = new_value
	_dialog_container.theme = new_value
	_dialog_container.update_outline_margin()

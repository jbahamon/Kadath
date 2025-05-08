extends VBoxContainer

@onready var title_menu = $TitleScreen
@onready var saves_menu = $SavesMenu
@onready var settings_menu = $SettingsMenu
@onready var credits = $Credits

@export var music: AudioStream
var current_menu: Control

func _ready():
	UIService.initialize_basic(
		$HelpBar,
		get_node("../UIControlPlayer"),
		get_node("../UINotificationPlayer"),
	)
	
	MusicService.initialize(
		get_node("../BGMPlayer")
	)
	
	MusicService.play_song(self.music)

	
	self.current_menu = title_menu
	self.current_menu.show_menu()
	
	
func switch_to_menu(menu: Control):
	menu.update_menu()
	self.current_menu.hide_menu()
	self.current_menu = menu
	self.current_menu.show_menu()
	
func _on_Quit_pressed():
	get_tree().quit()

func _on_New_Game_pressed():
	title_menu.disable_buttons()
	SceneSwitcher.load_scene("res://main/local_scene.tscn")
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.BLACK, 0.5)
	await DoAll.new([
		SceneSwitcher.scene_loaded,
		tween.finished
	]).execute()
	
	SceneSwitcher.change_scene()

func _on_Continue_Game_pressed():
	self.switch_to_menu(saves_menu)

func _on_Settings_pressed():
	self.switch_to_menu(settings_menu)
	
func _on_Credits_pressed() -> void:
	self.switch_to_menu(credits)

func _on_menu_exited():
	UIService.play_focus_sound()
	self.switch_to_menu(title_menu)

func _on_continue_game_focus_entered() -> void:
	UIService.set_menu_help(
		"Continue a previously saved game.",
		"[{ui_up}]/[{ui_down}]: Select [{ui_accept}]: Confirm"
	)

func _on_new_game_focus_entered() -> void:
	UIService.set_menu_help(
		"Start a new game.",
		"[{ui_up}]/[{ui_down}]: Select [{ui_accept}]: Confirm"
	)

func _on_settings_focus_entered() -> void:
	UIService.set_menu_help(
		"Change controls and other settings.",
		"[{ui_up}]/[{ui_down}]: Select [{ui_accept}]: Confirm"
	)

func _on_credits_focus_entered() -> void:
	UIService.set_menu_help(
		"Check the game's credits.",
		"[{ui_up}]/[{ui_down}]: Select [{ui_accept}]: Confirm"
	)

func _on_quit_focus_entered() -> void:
	UIService.set_menu_help(
		"Exit the game.",
		"[{ui_up}]/[{ui_down}]: Select [{ui_accept}]: Confirm"
	)

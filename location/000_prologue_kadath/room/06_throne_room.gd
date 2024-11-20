extends LocationRoom

@onready var floor = $Floor
@onready var walls = $Walls

var darken_tween = null
var fade_tween = null
var spooks_tween = null

func lock_pickman():
	EntitiesService.get_party().set_unlocked(PartyMember.Id.PICKMAN, false)
	
func fade_companion(mode: CutsceneInstruction.ExecutionMode):
	var companion = $NPCPickman
	var target_color = Color(0,0,0,0)
	if mode == CutsceneInstruction.ExecutionMode.PLAY:
		self.fade_tween = get_tree().create_tween()
		self.fade_tween.tween_property(companion, "modulate", Color.BLACK, 0.5)
		self.fade_tween.tween_property(companion, "modulate", target_color, 0.5)
		await self.fade_tween.finished
	else:
		companion.modulate = target_color
	
func darken_room(mode: CutsceneInstruction.ExecutionMode):
	if mode == CutsceneInstruction.ExecutionMode.PLAY:
		self.darken_tween = get_tree().create_tween()
		var method = func(color): 
			self.walls.modulate = color
			self.floor.modulate = color
		self.darken_tween.tween_method(method, Color.WHITE, Color.TRANSPARENT, 5)
		await self.darken_tween.finished
	else:
			self.walls.modulate = Color.TRANSPARENT
			self.floor.modulate = Color.TRANSPARENT
	
func show_spooks(mode: CutsceneInstruction.ExecutionMode):
	var spooks = $Spooks
	if mode == CutsceneInstruction.ExecutionMode.PLAY:
		spooks.modulate = Color(0,0,0,0)
		self.spooks_tween = get_tree().create_tween()
		self.spooks_tween.tween_property(spooks, "modulate", Color.WHITE, 0.5)
		await self.spooks_tween.finished
	else:
		spooks.modulate = Color.WHITE
	
func show_title_card():
	var party = EntitiesService.get_party()
	party.set_physics_process(false)
	SceneSwitcher.current_scene.exit()
	SceneSwitcher.go_to_scene("res://ui/04_templates/other/demo_end.tscn")

func pause_call(_function_name: String):
	pass
		
func resume_call(_function_name: String):
	pass
		
func skip_call(function_name: String):
	var tween
	match function_name:
		"darken_room":
			self.walls.modulate = Color.TRANSPARENT
			self.floor.modulate = Color.TRANSPARENT
			tween = darken_tween
		"fade_companion":
			$NPCPickman.modulate = Color.TRANSPARENT
			tween = fade_tween
		"show_spooks":
			$Spooks.modulate = Color.WHITE
			tween = spooks_tween

	if tween != null:
		tween.finished.emit()
		tween.kill()

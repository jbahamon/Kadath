extends LocationRoom

@onready var floor_layer = $Floor
@onready var walls_layer = $Walls

var music_tween = null
var dissolve_tween = null
var fade_tween = null
var walk_tween = null

func lock_pickman():
	EntitiesService.party.set_unlocked(PartyMember.Id.PICKMAN, false)

func fade_music(mode: CutsceneInstruction.ExecutionMode):
	if mode == CutsceneInstruction.ExecutionMode.PLAY:	
		music_tween = get_tree().create_tween()
		music_tween.tween_property(MusicService.player, "volume_linear", 0, 1.0)
		await music_tween.finished
	MusicService.player.stop()
	MusicService.player.volume_db = 0.0
				
func fade_companion(mode: CutsceneInstruction.ExecutionMode):
	var companion = $NPCPickman
	var target_color = Color(0,0,0,0)
	if mode == CutsceneInstruction.ExecutionMode.PLAY:
		self.fade_tween = get_tree().create_tween()
		self.fade_tween.tween_property(companion, "modulate", Color.BLACK, 0.5)
		await self.fade_tween.finished
	else:
		companion.modulate = target_color

func dissolve_room(mode: CutsceneInstruction.ExecutionMode):
	var carter = EntitiesService.get_entity("Carter")
	carter.z_index = 2
	var dissolve_texture: Sprite2D = $Sprite2D
	dissolve_texture.global_position = CameraService.camera.get_screen_center_position()
	var dissolve_material: ShaderMaterial = dissolve_texture.material
	if mode == CutsceneInstruction.ExecutionMode.PLAY:
		self.dissolve_tween = get_tree().create_tween()
		dissolve_tween.tween_property(dissolve_material, "shader_parameter/progress", 0.0, 7.0)
		await dissolve_tween.finished
	else:
		dissolve_material.set_shader_parameter("progress", 0.0)

func nyarla_walk(mode: CutsceneInstruction.ExecutionMode):
	var nyarla: AnimatedSprite2D = $Nyarlathotep
	
	nyarla.play("walk")
	if mode == CutsceneInstruction.ExecutionMode.PLAY:
		self.walk_tween = get_tree().create_tween()
		walk_tween.tween_property(nyarla, "position", Vector2(0, -32.0), 5.0)
		await self.walk_tween.finished
	else:
		nyarla.position = Vector2(0, -32.0)
	nyarla.play("default")
	
func show_title_card():
	var party = EntitiesService.party
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
		"nyarla_walk":
			$Nyarlathotep.position = Vector2(0, -32.0)
			$Nyarlathotep.play("default")
			tween = walk_tween
		"fade_music":
			self.walls.modulate = Color.TRANSPARENT
			self.floor.modulate = Color.TRANSPARENT
			tween = music_tween
		"fade_companion":
			$NPCPickman.modulate = Color.TRANSPARENT
			tween = fade_tween
		"dissolve_room":
			tween = dissolve_tween
			material.set_shader_parameter("progress", 0.0)
	if tween != null:
		tween.finished.emit()
		tween.kill()

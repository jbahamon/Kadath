extends LocationRoom

@onready var floor_layer = $Floor
@onready var walls_layer = $Walls

var music_tween = null
var dissolve_tween = null
var fade_tween = null
var walk_tween = null
var accelerate_tween = null

@onready var stars = $SpaceBG/Stars
@onready var nebula = $SpaceBG/Nebula
var stars_speed = Vector2(0.0, -0.05)
var nebula_speed = Vector2(0.0, -0.1)
var stars_offset = Vector2.ZERO
var nebula_offset = Vector2.ZERO

func lock_pickman():
	EntitiesService.party.set_unlocked(PartyMember.Id.PICKMAN, false)

func _process(delta: float):
	stars_offset.y = fmod(stars_offset.y + delta * stars_speed.y, 1.0)
	nebula_offset.y = fmod(nebula_offset.y + delta * nebula_speed.y, 1.0)
	stars.material.set_shader_parameter("offset", stars_offset)
	nebula.material.set_shader_parameter("offset", nebula_offset)
	
func fade_room(mode: CutsceneInstruction.ExecutionMode):
	if mode == CutsceneInstruction.ExecutionMode.PLAY:
		music_tween = get_tree().create_tween()
		music_tween.set_parallel()
		music_tween.tween_property($Floor, "modulate", Color.DIM_GRAY, 1.0)
		music_tween.tween_property($Walls, "modulate", Color.DIM_GRAY, 1.0)
		music_tween.tween_property(MusicService.player, "volume_linear", 0, 1.0)
		await music_tween.finished
	MusicService.player.stop()
	$Floor.modulate = Color.DIM_GRAY
	$Walls.modulate = Color.DIM_GRAY
	MusicService.player.volume_db = 0.0
				
func fade_companion(mode: CutsceneInstruction.ExecutionMode):
	var companion = $NPCPickman
	var sprite = companion.get_node("Anim/Sprite2D")
	companion.material.set_shader_parameter("frames", Vector2(sprite.hframes, sprite.vframes))
	if mode == CutsceneInstruction.ExecutionMode.PLAY:
		self.fade_tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		self.fade_tween.tween_property(companion.material, "shader_parameter/progress", 1.0, 2.0)
		await self.fade_tween.finished
	
	companion.material.set_shader_parameter("progress", 1.0)

func dissolve_room(mode: CutsceneInstruction.ExecutionMode):
	var carter = EntitiesService.get_entity("Carter")
	carter.z_index = 2
	var space_bg: Node2D = $SpaceBG
	space_bg.global_position = CameraService.camera.get_screen_center_position()
	var space_bg_material: ShaderMaterial = space_bg.material
	if mode == CutsceneInstruction.ExecutionMode.PLAY:
		self.dissolve_tween = get_tree().create_tween()
		dissolve_tween.tween_property(space_bg_material, "shader_parameter/progress", 0.0, 6.0)
		await dissolve_tween.finished
	else:
		space_bg_material.set_shader_parameter("progress", 0.0)

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

func accelerate(mode: CutsceneInstruction.ExecutionMode):
	if mode == CutsceneInstruction.ExecutionMode.PLAY:
		accelerate_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		accelerate_tween.set_parallel()
		
		accelerate_tween.tween_property(self, "stars_speed", Vector2(0.0, -0.5), 0.7)
		accelerate_tween.tween_property(self, "nebula_speed", Vector2(0.0, -1.0), 0.7)
		await accelerate_tween.finished
		
	self.stars_speed = Vector2(0.0, -0.5)
	self.nebula_speed = Vector2(0.0, -1.0)
		
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
		"fade_room":
			$Walls.modulate = Color.DIM_GRAY
			$Floor.modulate = Color.DIM_GRAY
			MusicService.player.volume_db = 0.0
			tween = music_tween
		"fade_companion":
			$NPCPickman.material.set_shader_parameter("progress", 1.0)
			tween = fade_tween
		"dissolve_room":
			tween = dissolve_tween
			$SpaceBG.material.set_shader_parameter("progress", 0.0)
		"accelerate":
			tween = accelerate_tween
			self.stars_speed = Vector2(0.0, -0.5)
			self.nebula_speed = Vector2(0.0, -1.0)
			
	if tween != null:
		tween.finished.emit()
		tween.kill()

func demo_end():
	var demo_end_ui = load("res://ui/03_organisms/demo_end_screen/demo_end_screen.tscn").instantiate()
	UIService.popup_layer.add_child(demo_end_ui)

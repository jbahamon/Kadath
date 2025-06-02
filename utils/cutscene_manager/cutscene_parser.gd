var SetRoom = preload("res://utils/cutscene_manager/instructions/set_room.gd")

var SetOverlay = preload("res://utils/cutscene_manager/instructions/set_overlay.gd")
var FadeOverlay = preload("res://utils/cutscene_manager/instructions/fade_overlay.gd")

var MoveCamera = preload("res://utils/cutscene_manager/instructions/move_camera.gd")
var AssignCamera = preload("res://utils/cutscene_manager/instructions/assign_camera.gd")

var DisableCollisions = preload("res://utils/cutscene_manager/instructions/disable_collisions.gd")
var EnableCollisions = preload("res://utils/cutscene_manager/instructions/enable_collisions.gd")

var Move = preload("res://utils/cutscene_manager/instructions/move.gd")
var LookAt = preload("res://utils/cutscene_manager/instructions/look_at.gd")

var Await = preload("res://utils/cutscene_manager/instructions/await.gd")
var Call = preload("res://utils/cutscene_manager/instructions/call.gd")
var Shake = preload("res://utils/cutscene_manager/instructions/shake.gd")
var StartDialogue = preload("res://utils/cutscene_manager/instructions/start_dialogue.gd")
var Narrate = preload("res://utils/cutscene_manager/instructions/narrate.gd")
var PlayMusic = preload("res://utils/cutscene_manager/instructions/play_music.gd")
var PlaySound = preload("res://utils/cutscene_manager/instructions/play_sound.gd")

var AssignProxy = preload("res://utils/cutscene_manager/instructions/assign_proxy.gd")

var Simultaneous = preload("res://utils/cutscene_manager/instructions/simultaneous.gd")
var Sequential = preload("res://utils/cutscene_manager/instructions/sequential.gd")

var Wait = preload("res://utils/cutscene_manager/instructions/wait.gd")

var patterns = {}

func _init():
	patterns["SET_OVERLAY"] = RegEx.new()
	patterns["SET_OVERLAY"].compile("(?<Overlay>.+) TO (?<Color>.+)$")
	
	patterns["FADE"] = RegEx.new()
	patterns["FADE"].compile("(?<Overlay>.+) TO (?<Color>.+) IN (?<Time>.+)$")
	
	patterns["MOVE"] = RegEx.new()
	patterns["MOVE"].compile("^(?<Character>.+) TO (?<Position>[^a-zA-Z]+)( AT (?<Speed>.+))?$")
	
	patterns["MOVE_CAMERA_TO_POSITION"] = RegEx.new()
	patterns["MOVE_CAMERA_TO_POSITION"].compile("TO (?<Position>[^a-zA-Z]+)( IN (?<Time>.+))?$")
	
	patterns["MOVE_CAMERA_TO_ENTITY"] = RegEx.new()
	patterns["MOVE_CAMERA_TO_ENTITY"].compile("TO (?<Entity>[^ ]+)( IN (?<Time>.+))?$")
	
	patterns["MOVE_CAMERA_BY"] = RegEx.new()
	patterns["MOVE_CAMERA_BY"].compile("BY (?<Displacement>[^a-zA-Z]+)( IN (?<Time>.+))?$")
	
	patterns["SET_POSITION"] = RegEx.new()
	patterns["SET_POSITION"].compile("^(?<Character>.+) TO (?<Position>.+)$")
	
	patterns["WALK"] = RegEx.new()
	patterns["WALK"].compile("^(?<Character>.+) TO (?<Position>.+) AT (?<Speed>.+)$")
		
	patterns["LOOK"] = RegEx.new()
	patterns["LOOK"].compile("^(?<Character>.+) (?<Direction>.+)$")
	
	patterns["LOOK_AT"] = RegEx.new()
	patterns["LOOK_AT"].compile("^(?<Character>.+) AT (?<Target>.+)$")
	
	patterns["PLAY_ANIM"] = RegEx.new()
	patterns["PLAY_ANIM"].compile("^(?<Character>.+) (?<Anim>.+)$")
	
	patterns["CALL"] = RegEx.new()
	patterns["CALL"].compile("^(?<Entity>[^ ]+) (?<FunctionName>[^ ]+)( (?<Args>.*)$|$)")
	
	patterns["START_DIALOGUE"] = RegEx.new()
	patterns["START_DIALOGUE"].compile("^(?<DialogueId>[^ ]+)( +AT +(?<Alignment>[^ ]+) *)?$")
	
	patterns["NARRATE"] = RegEx.new()
	patterns["NARRATE"].compile("^(?<DialogueId>.+)$")
	
	patterns["COLOR"] = RegEx.new()
	patterns["COLOR"].compile("\\([ ]*(?<R>[^ ,)]+)[ ]*,[ ]*(?<G>[^ ,)]+)[ ]*,[ ]*(?<B>[^ ,)]+)[ ]*,[ ]*(?<A>[^ ,)]+)[ ]*\\)")
	
	patterns["VECTOR2"] = RegEx.new()
	patterns["VECTOR2"].compile("\\([ ]*(?<X>[^ ,)]+)[ ]*,[ ]*(?<Y>[^ ,)]+)[ ]*\\)")

	patterns["SHAKE"] = RegEx.new()
	patterns["SHAKE"].compile("^(?<Entity>[^ ]+) FOR (?<Duration>.+) STR (?<Amplitude>.+) TIME_SCALE (?<TimeScaleFactor>.+)$")

	patterns["PLAY_MUSIC"] = RegEx.new()
	patterns["PLAY_MUSIC"].compile("^\"(?<SongName>.+)\"( AT (?<Offset>.+))?$")
	
	patterns["PLAY_SOUND"] = RegEx.new()
	patterns["PLAY_SOUND"].compile("^\"(?<StreamPath>.+)\" IN (?<Channel>[^ ]+)( AT (?<Position>.+))?$")
	

func parse_cutscene_from_file(cutscene_name: String): 
	var cutscene_file = FileAccess.open(cutscene_name, FileAccess.READ)
	var stack = self.get_initial_stack()
	
	while not cutscene_file.eof_reached():
		var line = cutscene_file.get_line()
		self.parse_line(stack, line)
	
	assert(len(stack) == 1, "Missing END instruction")
	return stack[0]
	
func parse_cutscene_from_array(instructions: Array): 
	var stack = self.get_initial_stack()
	for line in instructions:
		self.parse_line(stack, line)
	
	assert(len(stack) == 1, "Missing END instruction")
	return stack[0]

func get_initial_stack() -> Array:
	var stack = [
		Sequential.new()
	]
	stack[0].add_instruction(Wait.new(0))
	return stack
	
func parse_line(stack: Array, line: String):
	if line.strip_edges().begins_with("#"):
		return
			
	var tokens = line.strip_edges().split(" ", false, 1)

	if not tokens.is_empty():
		var instruction_name = tokens[0]
		var args = tokens[1] if tokens.size() > 1 else ""

		self.parse_instruction(stack, instruction_name, args)
			
func parse_instruction(stack: Array, instruction_name: String, args: String):
	var instruction_type = CutsceneInstruction.Type.get(instruction_name)
	
	var instruction
	
	match(instruction_type):
		CutsceneInstruction.Type.SET_ROOM:
			instruction = SetRoom.new(self.parse_string(args))

		CutsceneInstruction.Type.SET_OVERLAY:
			var set_match: RegExMatch = self.patterns["SET_OVERLAY"].search(args)
			instruction = SetOverlay.new(
				self.parse_string(set_match.get_string("Overlay")),
				self.parse_color(set_match.get_string("Color"))
			)
		CutsceneInstruction.Type.FADE_OVERLAY:
			var fade_match: RegExMatch = self.patterns["FADE"].search(args)
			instruction = FadeOverlay.new(
				self.parse_string(fade_match.get_string("Overlay")),
				self.parse_color(fade_match.get_string("Color")),
				self.parse_float(fade_match.get_string("Time"))
			)
		
		CutsceneInstruction.Type.MOVE_CAMERA:
			
			instruction = self.parse_move_camera(args)
				
		CutsceneInstruction.Type.ASSIGN_CAMERA:
			instruction = AssignCamera.new(self.parse_string(args))
			
		CutsceneInstruction.Type.LOOK:
			var look_match: RegExMatch = self.patterns["LOOK"].search(args)
			instruction = Call.new(
				self.parse_string(look_match.get_string("Character")),
				"set_orientation",
				[self.parse_direction(look_match.get_string("Direction"))]
			)
		CutsceneInstruction.Type.LOOK_AT:
			var look_at_match: RegExMatch = self.patterns["LOOK_AT"].search(args)
			
			var target = self.parse_vector2_opt(look_at_match.get_string("Target"))
			
			if target == null:
				target = self.parse_string(look_at_match.get_string("Target"))
			
			instruction = LookAt.new(
				self.parse_string(look_at_match.get_string("Character")),
				target
			)
		CutsceneInstruction.Type.SHAKE:
			var shake_match: RegExMatch = self.patterns["SHAKE"].search(args)
			instruction = Shake.new(
				self.parse_string(shake_match.get_string("Entity")),
				self.parse_float(shake_match.get_string("Duration")),
				self.parse_vector2(shake_match.get_string("Amplitude")),
				self.parse_float(shake_match.get_string("TimeScaleFactor")),
			)
				
			
		CutsceneInstruction.Type.SET_POSITION:
			var set_position_match: RegExMatch = self.patterns["SET_POSITION"].search(args)
			instruction = Call.new(
				self.parse_string(set_position_match.get_string("Character")),
				"set",
				["position", self.parse_vector2(set_position_match.get_string("Position"))]
			)
			
		CutsceneInstruction.Type.DISABLE_COLLISIONS:
			instruction = DisableCollisions.new(self.parse_string(args))
			
		CutsceneInstruction.Type.ENABLE_COLLISIONS:
			instruction = EnableCollisions.new(self.parse_string(args))
			
		CutsceneInstruction.Type.WALK:
			var walk_match: RegExMatch = self.patterns["WALK"].search(args)
			var entity = self.parse_string(walk_match.get_string("Character"))
			var target = self.parse_vector2_opt(walk_match.get_string("Position"))
			var speed = self.parse_float(walk_match.get_string("Speed"))
			instruction = Sequential.new()
			instruction.add_instruction(LookAt.new(entity, target))
			instruction.add_instruction(Call.new(entity, "play_anim", ["walk"]))
			instruction.add_instruction(Move.new(entity, target, speed))
			instruction.add_instruction(Call.new(entity, "play_anim", ["idle"]))
		
		CutsceneInstruction.Type.RUN:
			var walk_match: RegExMatch = self.patterns["WALK"].search(args)
			var entity = self.parse_string(walk_match.get_string("Character"))
			var target = self.parse_vector2_opt(walk_match.get_string("Position"))
			var speed = self.parse_float(walk_match.get_string("Speed"))
			instruction = Sequential.new()
			instruction.add_instruction(LookAt.new(entity, target))
			instruction.add_instruction(Call.new(entity, "play_anim", ["run"]))
			instruction.add_instruction(Move.new(entity, target, speed))
			instruction.add_instruction(Call.new(entity, "play_anim", ["idle"]))
				
		CutsceneInstruction.Type.MOVE:
			var walk_match: RegExMatch = self.patterns["MOVE"].search(args)
			var speed = walk_match.get_string("Speed")
			instruction = Move.new(
				self.parse_string(walk_match.get_string("Character")),
				self.parse_vector2_opt(walk_match.get_string("Position")),
				self.parse_float(speed) if speed != '' else INF
			)
		CutsceneInstruction.Type.PLAY_ANIM:
			var anim_match: RegExMatch = self.patterns["PLAY_ANIM"].search(args)
			instruction = Call.new(
				self.parse_string(anim_match.get_string("Character")),
				"play_anim",
				[self.parse_string(anim_match.get_string("Anim"))]
			)
		CutsceneInstruction.Type.CALL:
			var call_match: RegExMatch = self.patterns["CALL"].search(args)
			instruction = Call.new(
				self.parse_string(call_match.get_string("Entity")),
				self.parse_string(call_match.get_string("FunctionName")),
				call_match.get_string("Args").strip_edges().split(" ", false)
			)
		CutsceneInstruction.Type.AWAIT:
			var call_match: RegExMatch = self.patterns["CALL"].search(args)
			instruction = Await.new(
				self.parse_string(call_match.get_string("Entity")),
				self.parse_string(call_match.get_string("FunctionName")),
				call_match.get_string("Args").strip_edges().split(" ", false)
			)
		CutsceneInstruction.Type.START_DIALOGUE:
			var dialogue_match: RegExMatch = self.patterns["START_DIALOGUE"].search(args)			
			var alignment_match = dialogue_match.get_string("Alignment")
			var alignment = self.parse_dialogue_alignment(alignment_match) if alignment_match != '' else DialogueService.Alignment.BOTTOM
			instruction = StartDialogue.new(
				self.parse_string(dialogue_match.get_string("DialogueId")),
				alignment
			)
		CutsceneInstruction.Type.NARRATE:
			var narrate_match: RegExMatch = self.patterns["NARRATE"].search(args)
			instruction = Narrate.new(
				self.parse_string(narrate_match.get_string("DialogueId")),
			)
			
		CutsceneInstruction.Type.PLAY_MUSIC:
			var song_match: RegExMatch = self.patterns["PLAY_MUSIC"].search(args)
			var song = self.parse_string(song_match.get_string("SongName"))
			var offset = song_match.get_string("Offset")
			
			instruction = PlayMusic.new(
				"res://sound/music/%s.ogg" % song if song != "NONE" else "",
				parse_float(offset) if offset != '' else 0.0
			)
			
		CutsceneInstruction.Type.PLAY_SOUND:
			var sound_match: RegExMatch = self.patterns["PLAY_SOUND"].search(args)
			var stream = self.parse_string(sound_match.get_string("StreamPath"))
			var channel = self.parse_string(sound_match.get_string("Channel"))
			var position = sound_match.get_string("Position")
			
			instruction = PlaySound.new(
				"res://sound/%s.wav" % stream,
				channel,
				self.parse_vector2(position) if position != '' else null
			)
		CutsceneInstruction.Type.HIDE:
			instruction = Call.new(
				self.parse_string(args),
				"set_visible",
				[false]
			)
		CutsceneInstruction.Type.SHOW:
			instruction = Call.new(
				self.parse_string(args),
				"set_visible",
				[true]
			)
		CutsceneInstruction.Type.ASSIGN_PROXY:
			instruction = AssignProxy.new(self.parse_string(args))
		CutsceneInstruction.Type.SIMULTANEOUS:
			stack.push_back(Simultaneous.new())
		CutsceneInstruction.Type.SEQUENTIAL:
			stack.push_back(Sequential.new())
		CutsceneInstruction.Type.END:
			assert(len(stack) > 0, "Too many END instructions")
			instruction = stack.pop_back()
		CutsceneInstruction.Type.WAIT:
			instruction = Wait.new(self.parse_float(args))
			
		_:
			assert(false)
			instruction = null
			
	if instruction != null:
		stack.back().add_instruction(instruction)

func parse_string(raw_string: String) -> String:
	return raw_string.strip_edges()

func parse_int(raw_string: String) -> int:
	return int(raw_string.strip_edges())
	
func parse_float(raw_string: String) -> float:
	return float(raw_string.strip_edges())

func parse_color(color_string: String) -> Color:
	var color_match: RegExMatch = self.patterns["COLOR"].search(color_string)
	var r = float(color_match.get_string("R"))
	var g = float(color_match.get_string("G"))
	var b = float(color_match.get_string("B"))
	var a = float(color_match.get_string("A"))
	return Color(
		r if r <= 1 else r/256.0,
		g if g <= 1 else g/256.0,
		b if b <= 1 else b/256.0,
		a if a <= 1 else a/256.0
	)

func parse_vector2(position_string: String):
	var position_match: RegExMatch = self.patterns["VECTOR2"].search(position_string)
	
	if position_match != null:
		return Vector2(
			float(position_match.get_string("X")),
			float(position_match.get_string("Y"))
		)
	else:
		return null
		

func parse_vector2_opt(array_string: String):
	var position_match: RegExMatch = self.patterns["VECTOR2"].search(array_string)
	
	if position_match != null:
		return [
			float(position_match.get_string("X")) if position_match.get_string("X").strip_edges() != "_" else NAN,
			float(position_match.get_string("Y")) if position_match.get_string("Y").strip_edges() != "_" else NAN
		]
	else:
		return null

func parse_direction(direction_string: String) -> Vector2:
	match direction_string.strip_edges():
		"UP":
			return Vector2.UP
		"DOWN":
			return Vector2.DOWN
		"LEFT":
			return Vector2.LEFT
		"RIGHT":
			return Vector2.RIGHT
		_:
			return Vector2.DOWN

func parse_move_camera(args: String):
	var time_match
	var time
	
	var move_match: RegExMatch = self.patterns["MOVE_CAMERA_TO_POSITION"].search(args)
	if move_match != null:
		time_match = move_match.get_string("Time")
		time = self.parse_float(time_match) if time_match != '' else 0.0
		return MoveCamera.new(
			self.parse_vector2(move_match.get_string("Position")),
			"target_position",
			time
		)
	
	move_match = self.patterns["MOVE_CAMERA_TO_ENTITY"].search(args)
	if move_match != null:
		time_match = move_match.get_string("Time")
		time = self.parse_float(time_match) if time_match != '' else 0.0
		return MoveCamera.new(
			move_match.get_string("Entity"),
			"target_entity",
			time
		)
		
	move_match = self.patterns["MOVE_CAMERA_BY"].search(args)
	time_match = move_match.get_string("Time")
	time = self.parse_float(time_match) if time_match != '' else 0.0
	return MoveCamera.new(
		self.parse_vector2(move_match.get_string("Displacement")),
		"displacement",
		time
	)

func parse_dialogue_alignment(raw_alignment: String):
	match raw_alignment.to_upper():
		"TOP":
			return DialogueService.Alignment.TOP
		"CENTER":
			return DialogueService.Alignment.CENTER
		"BOTTOM":
			return DialogueService.Alignment.BOTTOM
		_:
			assert(false, "Incorrect alignment '%s' provided" % raw_alignment)
			return DialogueService.Alignment.BOTTOM

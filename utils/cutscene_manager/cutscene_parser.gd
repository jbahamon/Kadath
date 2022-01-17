var CutsceneInstruction = preload('res://utils/cutscene_manager/instructions/cutscene_instruction.gd')

var SetRoom = preload('res://utils/cutscene_manager/instructions/set_room.gd')

var SetOverlay = preload('res://utils/cutscene_manager/instructions/set_overlay.gd')
var FadeOverlay = preload('res://utils/cutscene_manager/instructions/fade_overlay.gd')

var SetCamera = preload('res://utils/cutscene_manager/instructions/set_camera.gd')
var MoveCamera = preload('res://utils/cutscene_manager/instructions/move_camera.gd')
var AssignCamera = preload('res://utils/cutscene_manager/instructions/assign_camera.gd')

var Walk = preload('res://utils/cutscene_manager/instructions/walk.gd')
var Call = preload('res://utils/cutscene_manager/instructions/call.gd')
var StartDialog = preload('res://utils/cutscene_manager/instructions/start_dialog.gd')

var Simultaneous = preload('res://utils/cutscene_manager/instructions/simultaneous.gd')
var Sequential = preload('res://utils/cutscene_manager/instructions/sequential.gd')
var End = preload('res://utils/cutscene_manager/instructions/end.gd')
var Wait = preload('res://utils/cutscene_manager/instructions/wait.gd')

var patterns = {}

func _init():
	patterns["FADE"] = RegEx.new()
	patterns["FADE"].compile("TO (?<Color>.+) IN (?<Time>.+)$")
	
	patterns["MOVE"] = RegEx.new()
	patterns["MOVE"].compile("TO (?<Position>.+) IN (?<Time>.+)$")
	
	patterns["WALK"] = RegEx.new()
	patterns["WALK"].compile("^(?<Character>.+) TO (?<Position>.+) AT (?<Speed>.+)$")
		
	patterns["LOOK"] = RegEx.new()
	patterns["LOOK"].compile("^(?<Character>.+) (?<Direction>.+)$")
	
	patterns["PLAY_ANIM"] = RegEx.new()
	patterns["PLAY_ANIM"].compile("^(?<Character>.+) (?<Anim>.+)$")
	
	patterns["CALL"] = RegEx.new()
	patterns["CALL"].compile("^(?<Entity>.+) (?<FunctionName>.+) (?<Args>.+)$")
	
	patterns["START_DIALOG"] = RegEx.new()
	patterns["START_DIALOG"].compile("^(?<DialogId>.+) ID (?<NodeId>.+) SOURCE (?<Source>.+)$")
	
	patterns["COLOR"] = RegEx.new()
	patterns["COLOR"].compile("\\([ ]*(?<R>[^ ,)]+)[ ]*,[ ]*(?<G>[^ ,)]+)[ ]*,[ ]*(?<B>[^ ,)]+)[ ]*,[ ]*(?<A>[^ ,)]+)[ ]*\\)")
	
	patterns["POSITION"] = RegEx.new()
	patterns["POSITION"].compile("\\([ ]*(?<X>[^ ,)]+)[ ]*,[ ]*(?<Y>[^ ,)]+)[ ]*\\)")

func parse_cutscene(cutscene_name: String) -> Array: 
	var cutscene_file = File.new()
	cutscene_file.open("res://cutscenes/%s.txt" % cutscene_name, File.READ)
	var instructions = []

	while not cutscene_file.eof_reached():
		var line = cutscene_file.get_line()
		var tokens = line.strip_edges().split(' ', false, 1)

		if not tokens.empty():
			var instruction_name = tokens[0]
			var args = tokens[1].strip_edges() if tokens.size() > 1 else ""
			
			var new_instruction = self.parse_instruction(instruction_name, args)
			
			if new_instruction != null:
				instructions.append(new_instruction)

	return instructions

func parse_instruction(instruction_name: String, args: String):
	var instruction = CutsceneInstruction.new()
	var instruction_type = CutsceneInstruction.Type.get(instruction_name)
	
	match(instruction_type):
		CutsceneInstruction.Type.SET_ROOM:
			return SetRoom.new(args.strip_edges())
		CutsceneInstruction.Type.SET_OVERLAY:
			return SetOverlay.new(
				self.parse_color(args)
			)
		CutsceneInstruction.Type.FADE_OVERLAY:
			var fade_match: RegExMatch = self.patterns["FADE"].search(args)
			return FadeOverlay.new(
				self.parse_color(fade_match.get_string("Color")),
				float(fade_match.get_string("Time").strip_edges())
			)
		CutsceneInstruction.Type.SET_CAMERA:
			return SetCamera.new(
				self.parse_position(args)
			)
		CutsceneInstruction.Type.MOVE_CAMERA:
			var move_match: RegExMatch = self.patterns["MOVE"].search(args)
			return MoveCamera.new(
				self.parse_position(move_match.get_string("Position")),
				float(move_match.get_string("Time").strip_edges())
			)
		CutsceneInstruction.Type.ASSIGN_CAMERA:
			return AssignCamera.new(args.strip_edges())
		CutsceneInstruction.Type.LOOK:
			var look_match: RegExMatch = self.patterns["LOOK"].search(args)
			return Call.new(
				look_match.get_string("Character").strip_edges(),
				"set_orientation",
				[self.parse_direction(look_match.get_string("Direction"))]
			)
		CutsceneInstruction.Type.WALK:
			var walk_match: RegExMatch = self.patterns["WALK"].search(args)
			return Walk.new(
				walk_match.get_string("Character").strip_edges(),
				self.parse_position(walk_match.get_string("Position")),
				float(walk_match.get_string("Speed").strip_edges())
			)
		CutsceneInstruction.Type.PLAY_ANIM:
			var anim_match: RegExMatch = self.patterns["PLAY_ANIM"].search(args)
			return Call.new(
				anim_match.get_string("Character").strip_edges(),
				"play_anim",
				[anim_match.get_string("Anim").strip_edges()]
			)
		CutsceneInstruction.Type.PLAY_ANIM:
			var call_match: RegExMatch = self.patterns["PLAY_ANIM"].search(args)
			return Call.new(
				call_match.get_string("Entity").strip_edges(),
				call_match.get_string("FunctionName").strip_edges(),
				call_match.get_string("Args").strip_edges().split(" ", false)
			)
		CutsceneInstruction.Type.START_DIALOG:
			var dialog_match: RegExMatch = self.patterns["START_DIALOG"].search(args)
			return StartDialog.new(
				dialog_match.get_string("DialogId").strip_edges(),
				float(dialog_match.get_string("NodeId").strip_edges()),
				dialog_match.get_string("Source").strip_edges()
			)
		CutsceneInstruction.Type.SIMULTANEOUS:
			return Simultaneous.new()
		CutsceneInstruction.Type.SEQUENTIAL:
			return Sequential.new()
		CutsceneInstruction.Type.END:
			return End.new()
		CutsceneInstruction.Type.WAIT:
			return Wait.new(float(args.strip_edges()))
		_:
			return null

func parse_color(color_string: String) -> Color:
	var color_match: RegExMatch = self.patterns["COLOR"].search(color_string)

	return Color(
		float(color_match.get_string("R")),
		float(color_match.get_string("G")),
		float(color_match.get_string("B")),
		float(color_match.get_string("A"))
	)

func parse_position(position_string: String) -> Vector2:
	var position_match: RegExMatch = self.patterns["POSITION"].search(position_string)
	
	return Vector2(
		float(position_match.get_string("X")),
		float(position_match.get_string("Y"))
	)

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

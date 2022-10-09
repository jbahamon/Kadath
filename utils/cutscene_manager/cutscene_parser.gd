var CutsceneInstruction = preload("res://utils/cutscene_manager/instructions/cutscene_instruction.gd")

var SetRoom = preload("res://utils/cutscene_manager/instructions/set_room.gd")

var SetOverlay = preload("res://utils/cutscene_manager/instructions/set_overlay.gd")
var FadeOverlay = preload("res://utils/cutscene_manager/instructions/fade_overlay.gd")

var SetCamera = preload("res://utils/cutscene_manager/instructions/set_camera.gd")
var MoveCamera = preload("res://utils/cutscene_manager/instructions/move_camera.gd")
var AssignCamera = preload("res://utils/cutscene_manager/instructions/assign_camera.gd")

var DisableCollisions = preload("res://utils/cutscene_manager/instructions/disable_collisions.gd")
var EnableCollisions = preload("res://utils/cutscene_manager/instructions/enable_collisions.gd")

var Move = preload("res://utils/cutscene_manager/instructions/move.gd")
var LookAt = preload("res://utils/cutscene_manager/instructions/look_at.gd")
var Call = preload("res://utils/cutscene_manager/instructions/call.gd")
var StartDialog = preload("res://utils/cutscene_manager/instructions/start_dialog.gd")

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
	
	patterns["MOVE_CAMERA_TO"] = RegEx.new()
	patterns["MOVE_CAMERA_TO"].compile("TO (?<Position>.+) IN (?<Time>.+)$")
	
	patterns["MOVE_CAMERA_BY"] = RegEx.new()
	patterns["MOVE_CAMERA_BY"].compile("(?<Position>.+) IN (?<Time>.+)$")
	
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
	patterns["CALL"].compile("^(?<Entity>.+) (?<FunctionName>.+)( (?<Args>.*)$|$)")
	
	patterns["START_DIALOG"] = RegEx.new()
	patterns["START_DIALOG"].compile("^(?<DialogId>.+) ID (?<NodeId>.+) SOURCE (?<Source>.+)$")
	
	patterns["COLOR"] = RegEx.new()
	patterns["COLOR"].compile("\\([ ]*(?<R>[^ ,)]+)[ ]*,[ ]*(?<G>[^ ,)]+)[ ]*,[ ]*(?<B>[^ ,)]+)[ ]*,[ ]*(?<A>[^ ,)]+)[ ]*\\)")
	
	patterns["POSITION"] = RegEx.new()
	patterns["POSITION"].compile("\\([ ]*(?<X>[^ ,)]+)[ ]*,[ ]*(?<Y>[^ ,)]+)[ ]*\\)")


func parse_cutscene_from_file(cutscene_name: String): 
	var cutscene_file = File.new()
	cutscene_file.open("res://cutscenes/%s.txt" % cutscene_name, File.READ)
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

	if not tokens.empty():
		var instruction_name = tokens[0]
		var args = tokens[1].strip_edges() if tokens.size() > 1 else ""

		self.parse_instruction(stack, instruction_name, args)
			
func parse_instruction(stack: Array, instruction_name: String, args: String):
	var instruction_type = CutsceneInstruction.Type.get(instruction_name)
	
	var instruction
	
	match(instruction_type):
		CutsceneInstruction.Type.SET_ROOM:
			instruction = SetRoom.new(args.strip_edges())
		CutsceneInstruction.Type.SET_OVERLAY:
			var set_match: RegExMatch = self.patterns["SET_OVERLAY"].search(args)
			instruction = SetOverlay.new(
				set_match.get_string("Overlay").strip_edges(),
				self.parse_color(set_match.get_string("Color"))
			)
		CutsceneInstruction.Type.FADE_OVERLAY:
			var fade_match: RegExMatch = self.patterns["FADE"].search(args)
			instruction = FadeOverlay.new(
				fade_match.get_string("Overlay").strip_edges(),
				self.parse_color(fade_match.get_string("Color")),
				float(fade_match.get_string("Time").strip_edges())
			)
		CutsceneInstruction.Type.SET_CAMERA:
			instruction = SetCamera.new(
				self.parse_position(args)
			)
		CutsceneInstruction.Type.MOVE_CAMERA:
			var mode: String
			var position
			var move_match: RegExMatch = self.patterns["MOVE_CAMERA_TO"].search(args)
			if move_match != null:
				var position_string = move_match.get_string("Position")
				position = self.parse_position(position_string)
				
				if position == null:
					mode = "target_entity"
					position = position_string
				else:
					mode = "target_position"
			
			else:
				mode = "displacement"
				move_match = self.patterns["MOVE_CAMERA_BY"].search(args)
				var position_string = move_match.get_string("Position")
				position = self.parse_position(position_string)
			
			instruction = MoveCamera.new(
				position,
				mode,
				float(move_match.get_string("Time").strip_edges())
			)
				
		CutsceneInstruction.Type.ASSIGN_CAMERA:
			instruction = AssignCamera.new(args.strip_edges())
		CutsceneInstruction.Type.LOOK:
			var look_match: RegExMatch = self.patterns["LOOK"].search(args)
			instruction = Call.new(
				look_match.get_string("Character").strip_edges(),
				"set_orientation",
				[self.parse_direction(look_match.get_string("Direction"))]
			)
		CutsceneInstruction.Type.LOOK_AT:
			var look_at_match: RegExMatch = self.patterns["LOOK_AT"].search(args)
			
			var target = self.parse_position(look_at_match.get_string("Target").strip_edges())
			
			if target == null:
				look_at_match.get_string("Target").strip_edges()
			
			instruction = LookAt.new(
				look_at_match.get_string("Character").strip_edges(),
				target
			)
		CutsceneInstruction.Type.SET_POSITION:
			var set_position_match: RegExMatch = self.patterns["SET_POSITION"].search(args)
			instruction = Call.new(
				set_position_match.get_string("Character").strip_edges(),
				"set_position",
				[self.parse_position(set_position_match.get_string("Position"))]
			)
			
		CutsceneInstruction.Type.DISABLE_COLLISIONS:
			instruction = DisableCollisions.new(args.strip_edges())
			
		CutsceneInstruction.Type.ENABLE_COLLISIONS:
			instruction = EnableCollisions.new(args.strip_edges())
			
		CutsceneInstruction.Type.WALK:
			var walk_match: RegExMatch = self.patterns["WALK"].search(args)
			var entity = walk_match.get_string("Character").strip_edges()
			var target = self.parse_position(walk_match.get_string("Position"))
			var speed = float(walk_match.get_string("Speed").strip_edges())
			instruction = Sequential.new()
			instruction.add_instruction(LookAt.new(entity, target))
			instruction.add_instruction(Call.new(entity, "play_anim", ["walk"]))
			instruction.add_instruction(Move.new(entity, target, speed))
			instruction.add_instruction(Call.new(entity, "play_anim", ["idle"]))
			
		CutsceneInstruction.Type.MOVE:
			var walk_match: RegExMatch = self.patterns["MOVE"].search(args)
			instruction = Move.new(
				walk_match.get_string("Character").strip_edges(),
				self.parse_position(walk_match.get_string("Position")),
				float(walk_match.get_string("Speed").strip_edges())
			)
		CutsceneInstruction.Type.PLAY_ANIM:
			var anim_match: RegExMatch = self.patterns["PLAY_ANIM"].search(args)
			instruction = Call.new(
				anim_match.get_string("Character").strip_edges(),
				"play_anim",
				[anim_match.get_string("Anim").strip_edges()]
			)
		CutsceneInstruction.Type.CALL:
			var call_match: RegExMatch = self.patterns["CALL"].search(args)
			instruction = Call.new(
				call_match.get_string("Entity").strip_edges(),
				call_match.get_string("FunctionName").strip_edges(),
				call_match.get_string("Args").strip_edges().split(" ", false)
			)
		CutsceneInstruction.Type.START_DIALOG:
			var dialog_match: RegExMatch = self.patterns["START_DIALOG"].search(args)
			instruction = StartDialog.new(
				dialog_match.get_string("DialogId").strip_edges(),
				float(dialog_match.get_string("NodeId").strip_edges()),
				dialog_match.get_string("Source").strip_edges()
			)
		CutsceneInstruction.Type.HIDE:
			instruction = Call.new(
				args.strip_edges(),
				"set_visible",
				[false]
			)
		CutsceneInstruction.Type.SHOW:
			instruction = Call.new(
				args.strip_edges(),
				"set_visible",
				[true]
			)
		CutsceneInstruction.Type.ASSIGN_PROXY:
			instruction = AssignProxy.new(args.strip_edges())
		CutsceneInstruction.Type.SIMULTANEOUS:
			stack.push_back(Simultaneous.new())
		CutsceneInstruction.Type.SEQUENTIAL:
			stack.push_back(Sequential.new())
		CutsceneInstruction.Type.END:
			assert(len(stack) > 0, "Too many END instructions")
			instruction = stack.pop_back()
		CutsceneInstruction.Type.WAIT:
			instruction = Wait.new(float(args.strip_edges()))
			
		_:
			assert(false)
			instruction = null
			
	if instruction != null:
		stack.back().add_instruction(instruction)

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

func parse_position(position_string: String):
	var position_match: RegExMatch = self.patterns["POSITION"].search(position_string)
	
	if position_match != null:
		return Vector2(
			float(position_match.get_string("X")),
			float(position_match.get_string("Y"))
		)
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

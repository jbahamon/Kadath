extends CutsceneInstruction

signal resumed

var instructions: Array = []
var current_mode = ExecutionMode.PLAY
var paused = false
var current_instruction = null

func execute(tree: SceneTree, mode: ExecutionMode):
	self.current_mode = mode

	for instruction in instructions:
		if not self.paused:
			self.current_instruction = instruction
			await instruction.run(tree, self.current_mode)
		else:
			await self.resumed
		
func add_instruction(instruction):
	self.instructions.append(instruction)

func _to_string():
	return "start_sequential"
	
func pause(tree: SceneTree):
	self.paused = true
	if self.current_instruction != null:
		self.current_instruction.pause(tree)

func resume(tree: SceneTree):
	assert(self.paused)
	self.paused = false
	if self.current_instruction != null:
		self.current_instruction.resume(tree)
	self.resumed.emit()
	
func skip(tree: SceneTree):
	self.current_mode = ExecutionMode.SKIP
	self.paused = false
	if self.current_instruction != null:
		self.current_instruction.skip(tree)
		print("skipping ", self.current_instruction)
	

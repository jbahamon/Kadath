extends CutsceneInstruction

signal completed

var instructions: Array

var _pending: Array
var _completed := false
var current_mode

func _init():
	self.instructions = []
	
func execute(tree: SceneTree, mode: ExecutionMode):
	self.current_mode = mode
	self._pending = [] + self.instructions
	self._completed = false
	
	for instruction in instructions:
		self._call_instruction(tree, instruction, mode)
	
	if not self._completed:
		await self.completed
		
func _call_instruction(tree: SceneTree, instruction, mode: ExecutionMode) -> void:
	await instruction.run(tree, mode)
	self._pending.erase(instruction)
	
	if self._pending.is_empty() and not self._completed:
		self.complete()
		
func complete():
	self.completed.emit()
	self._completed = true
	
func add_instruction(instruction):
	self.instructions.append(instruction)

func pause(tree: SceneTree):
	for instruction in self._pending:
		instruction.pause(tree)

func resume(tree: SceneTree):
	for instruction in self._pending:
		instruction.resume(tree)

func skip(tree: SceneTree):
	var pending = []  + self._pending
	for instruction in pending:
		print("skipping ", instruction)
		instruction.skip(tree)
	
func _to_string():
	return "start_simultaneous"

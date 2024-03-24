extends "res://utils/cutscene_manager/instructions/cutscene_instruction.gd"

signal completed

var instructions: Array

var _pending: Array
var _completed := false

func _init():
	self.instructions = []
	
func execute(tree: SceneTree):
	self._pending = [] + self.instructions
	self._completed = false
	
	for idx in range(len(instructions)):
		self._call_instruction(tree, instructions[idx])
	
	if not self._completed:
		await self.completed
		
func _call_instruction(tree: SceneTree, instruction) -> void:
	await instruction.run(tree)
	self._pending.erase(instruction)
	
	if self._pending.is_empty() and not self._completed:
		self.completed.emit()
		self._completed = true
	
func add_instruction(instruction):
	self.instructions.append(instruction)
	
func _to_string():
	return "start_simultaneous"

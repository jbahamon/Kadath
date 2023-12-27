class_name DoAll

signal done
var instructions: Array

var _pending: Array
var _completed := false

func _init(lambdas):
	self.instructions = lambdas
	
func execute():
	self._pending = [] + self.instructions
	self._completed = false
	
	for idx in range(len(instructions)):
		self._call_instruction(instructions[idx])
	
	if not self._completed:
		await self.done
		
func _call_instruction(instruction) -> void:
	await instruction.call()
	self._pending.erase(instruction)
	
	if self._pending.is_empty() and not self._completed:
		self.emit_signal("done")
		self._completed = true

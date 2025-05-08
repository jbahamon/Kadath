class_name DoAll

signal done
var instructions: Array

var _pending: Array
var _completed := false

func _init(lambdas):
	self.instructions = lambdas
	
func execute():
	self._completed = false
	
	if self.instructions.size() == 1:
		if self.instructions[0] is Callable:
			await self.instructions[0].call()
		else:
			await self.instructions[0]
		self.done.emit()
		self._completed = true
	else:
		self._pending = [] + self.instructions
	
		for idx in range(len(instructions)):
			self._call_instruction(instructions[idx])
	
	if not self._completed and self.instructions.size() > 0:
		await self.done
		
func _call_instruction(instruction) -> void:
	if instruction is Callable:
		await instruction.call()
	else:
		await instruction
	self._pending.erase(instruction)
	
	if self._pending.is_empty() and not self._completed:
		self.done.emit()
		self._completed = true

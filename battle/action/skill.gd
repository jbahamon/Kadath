extends CompositeBattleOption

@export var prompt = "Select a skill"
@export var description = "Use a skill"


func get_prompt():
	return self.prompt
	
func get_options():
	var options = []
	for child in self.get_children():
		if child.unlocked:
			options.append(child)
	
	return options
	
	

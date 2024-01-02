extends CompositeBattleOption

@export var prompt = "Select a skill"
@export var description = "Use a skill"


func get_prompt():
	return self.prompt
	
func get_options():
	return self.get_children()

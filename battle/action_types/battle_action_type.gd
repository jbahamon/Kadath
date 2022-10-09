extends Node

class_name BattleActionType
export var prompt: String = "Select an item"
export var action_name: String
export var description: String
export var disabled: bool = false

func get_prompt():
	return prompt

func get_actions():
	return self.get_children()

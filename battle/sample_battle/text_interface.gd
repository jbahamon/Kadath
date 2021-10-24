extends Control

class_name BattleUI

var buttons

signal action
signal targets

func initialize():
	buttons = $Buttons

func choose_action(actor: Battler) -> BattleAction:
	var actions = actor.get_actions()
	
	self.clear_buttons()
	for action in actions:
		var button = Button.new()
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.text = action.name
		button.connect("pressed", self, "on_action_selected", [action])
		buttons.add_child(button)
	
	return yield(self, "action")

func on_action_selected(action: BattleAction):
	emit_signal("action", action)

func clear_buttons():
	for button in buttons.get_children():
		buttons.remove_child(button)
		button.queue_free()
	
func choose_targets(battlers: Array):
	clear_buttons()
	for battler in battlers:
		var button = Button.new()
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.text = battler.name
		button.connect("pressed", self, "on_battler_selected", [battler])
		buttons.add_child(button)
		
	
	return yield(self, "targets")
	
func on_battler_selected(battler: Battler):
	emit_signal("targets", [battler])

extends BattlerAI

signal turn_chosen

var actors: Array
var action: BattleAction
var action_signature: Array
var current_action_argument: int
var action_arguments: Dictionary

func get_turn(actors: Array) -> Turn:
	self.actors = actors
	var actor = self.get_parent().get_parent()
	self.action = null
	
	self.interface.connect("option_selected", self, "on_option_selected")
	self.interface.connect("cancel", self, "on_cancel")
	self.request_action()
	yield(self, "turn_chosen")
	self.interface.disconnect("option_selected", self, "on_option_selected")
	self.interface.disconnect("cancel", self, "on_cancel")
	
	var turn = Turn.new()
	turn.actor = actor
	turn.action = self.action
	turn.action_args = self.action_arguments
	
	
	return turn

func on_option_selected(option):
	if option is BattleAction and self.action == null:
		self.action = option
		self.action_signature = self.action.get_signature()
		self.action_arguments = {}
		self.current_action_argument = 0
	else:
		var argument_name = self.action_signature[self.current_action_argument]["name"]
		var argument_value = option.get_value() if option.has_method("get_value") else option
		self.action_arguments[argument_name] = argument_value
		self.current_action_argument += 1
	
	if self.current_action_argument < self.action_signature.size():
		self.request_argument(
			self.get_parent().get_parent(), 
			self.actors, 
			self.action_signature[self.current_action_argument]
		)
	else:
		self.emit_signal("turn_chosen")

func on_cancel():
	if current_action_argument <= 0:
		self.action = null
		self.request_action()
	else:
		self.current_action_argument -= 1
		var argument_name = self.action_signature[self.current_action_argument]["name"]
		self.action_arguments.erase(argument_name)
		self.request_argument(
			self.get_parent(), 
			self.actors, 
			self.action_signature[self.current_action_argument]
		)

func request_action():
	var battler = self.get_parent()
	var actions = battler.get_actions()
	self.interface.request_action(actions)

func request_argument(actor, actors, argument):
	self.interface.request_argument(actor, actors, argument)
	

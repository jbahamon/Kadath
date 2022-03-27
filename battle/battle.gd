extends Node

signal battle_ended

# The Battle should handle initialization: this is, connecting characters
# to the loop, and handling restoring everything to its normal state once the 
# battle has finished

onready var loop: BattleLoop = $BattleLoop
onready var ui: BattleUI = $CanvasLayer/BattleUI


func start(party_members: Array, battlers: Array):
	
	self.loop.initialize(battlers, ui)
	self.ui.initialize(party_members)
	self.ui.show()

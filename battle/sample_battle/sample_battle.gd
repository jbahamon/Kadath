extends Node

export var ui_path: NodePath

var battlers: Array
var ui: BattleUI

func _ready():
	ui = get_node(ui_path)
	ui.initialize()
	
	battlers = [$Enemy, $PartyMember/Battler]
	
	$Enemy.stats.reset()
	$PartyMember.update_stats()	
	var loop = BattleLoop
	loop.initialize(battlers, ui)
	
	var ret = loop.do_battle()
	if ret is GDScriptFunctionState:
		yield(ret, "completed")
	
	

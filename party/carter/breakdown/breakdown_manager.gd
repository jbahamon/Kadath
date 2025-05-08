extends Node

@export var breakdown_material: Material
@onready var particles: CPUParticles2D = $Particles
@onready var breakdown_ai = $AI
var old_ai

func start():
	var parent = self.get_parent()
	await BattleService.prompt("%s can't take it anymore!" % parent.display_name)
	await parent.show_toast("Breakdown!", Color.BROWN)
	
	parent.material = self.breakdown_material
	self.particles.restart()
	self.particles.emitting = true
	self.particles.visible = true
	
	self.old_ai = parent.battler.ai
	parent.battler.ai = self.breakdown_ai
	
func stop(battle_ended):
	var parent = get_parent()
	
	if not battle_ended:
		await parent.show_toast("Stability regained")
	
	parent.material = null
	
	self.particles.emitting = false
	self.particles.visible = false
	
	parent.battler.ai = self.old_ai
	self.old_ai = null
	parent.battler.energy = max(1, parent.battler.energy)

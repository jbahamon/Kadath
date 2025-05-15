extends "res://party/lib/breakdown_manager.gd"

@export var breakdown_material: Material
@onready var particles: CPUParticles2D = $Particles


func start():
	await super.start()
	self.get_parent().material = self.breakdown_material
	self.particles.restart()
	self.particles.emitting = true
	self.particles.visible = true
	
	
func stop(battle_ended):
	await super.stop(battle_ended)
	self.particles.emitting = false
	self.particles.visible = false
	
	get_parent().parent.material = null
	

extends BattleAction

const base_use_sound: AudioStream = preload("res://sound/fx/item/Default - harvey656.wav")
const sparkle_scene = preload("res://battle/fx/item_sparkle.tscn") 

var item = null
var targets = null
var currently_highlighted_targets = null
var stored_materials = []
var sparkle: AnimatedSprite2D
var particles: CPUParticles2D

func _init() -> void:
	self.sparkle = sparkle_scene.instantiate()
	self.particles = sparkle.get_node("Particles")
	self.sparkle.visible = false
	
func reset():
	self.item = null
	self.targets = null
	
func get_next_parameter_signature():
	if self.item == null:
		return {
			"name": "item",
			"type": BattleAction.ActionArgument.ITEM,
			"prompt": "Choose an item",
		}
	elif self.targets == null and self.item.needs_targets():
		return {
			"name": "targets",
			"type": BattleAction.ActionArgument.TARGET,
			"targeting_type": self.item.target_type,
			"prompt": "Use %s on..." % self.item.display_name,
		}
	else:
		return null
	
func push_parameter(parameter_name, value):
	match parameter_name:
		"item":
			self.item = value
		"targets":
			self.targets = value
			self.stop_highlight()
	
func pop_parameter() -> bool:
	if self.targets != null:
		self.targets = null
		return true
	elif self.item != null:
		self.stop_highlight()
		self.item = null
		return true
	
	return false
	
func execute(actor):
	actor.play_anim("use_item")
	await actor.get_tree().create_timer(0.4).timeout
	FXService.play_sfx_at(self.base_use_sound, actor.global_position)
	
	actor.add_child(self.sparkle)
	self.particles.restart()

	self.sparkle.offset = Vector2(-7, -57)
	self.particles.position = Vector2(0, -50)

	self.sparkle.visible = true
	self.particles.emitting = true

	var tween = actor.get_tree().create_tween().set_parallel(true)
	tween.tween_property(self.sparkle, "offset", Vector2(-7, -97), 0.75)
	tween.tween_property(particles, "position", Vector2(0.5, -90.5), 0.75)
	await tween.finished
	particles.emitting = false
	self.sparkle.visible = false
	actor.remove_child(self.sparkle)

	var used 
	if not self.item.needs_targets():
		used = await self.item.use_in_battle()
	elif self.item.is_multi_target():
		# Then it's a multi target option
		used = await self.item.use_in_battle(self.targets.get_targets())
	else:
		# Then it's a single target
		used = await self.item.use_in_battle([self.targets])
	
	actor.play_anim("battle_idle")
	
	if actor is PartyMember and used and self.item.consumed_after_use:
		EntitiesService.party.inventory.remove(self.item.id, 1)

	self.reset()

func highlight_option(_actor, option):
	if self.item == null: # this is an item option
		BattleService.announce(ItemService.id_to_item(option[0]).description)
	
	if option is Array or not self.item.needs_targets():
		return

	if self.currently_highlighted_targets 	!= option:
		self.stop_highlight()
		self.start_highlight(option)
			
func start_highlight(option):
	self.currently_highlighted_targets = option
	
	if self.item.is_multi_target():
		self.stored_materials = []	
		for target in option.get_targets():
			self.stored_materials.append(target.material)
			target.material = self.highlight_material
	else:
		self.stored_materials = option.material
		option.material = self.highlight_material
	
func stop_highlight():
	if self.item == null or not self.item.needs_targets() or self.currently_highlighted_targets == null:
		return

	if self.item.is_multi_target():
		var highlighted_targets = self.currently_highlighted_targets.get_targets()
		for i in range(highlighted_targets.size()):
			highlighted_targets[i].material = stored_materials[i]
	else:
		self.currently_highlighted_targets.material = self.stored_materials
		
	self.stored_materials = []
	self.currently_highlighted_targets = null

func get_targets_custom(actor, actors):
	return self.item.get_targets_custom(actor, actors)

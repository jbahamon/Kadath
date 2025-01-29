extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D

func reset():
	self.position = Vector2.ZERO

func get_actors_at(target_position: Vector2) -> Array:
	self.global_position = target_position
	self.area.set_deferred("monitoring", true)
	
	var tree = get_tree()
	await tree.process_frame
	await tree.physics_frame
	await tree.physics_frame
	
	var hitboxes = self.area.get_overlapping_areas()
	
	return hitboxes.map(func(hitbox): return hitbox.get_parent().get_parent())

func animate():
	sprite.modulate = Color(Color.VIOLET, 0.35)
	sprite.scale = Vector2.ZERO
	self.visible = true
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.5)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.6).set_delay(0.2)
	await tween.finished
	self.visible = false
	sprite.modulate = Color(Color.WHITE, 0.266)

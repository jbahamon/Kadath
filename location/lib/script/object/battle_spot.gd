extends Marker2D

@onready var party_spots = $PartySpots
@onready var enemy_spots = $EnemySpots

func get_enemy_spots() -> Array:
	return enemy_spots.get_children()

func get_party_spots() -> Array:
	return party_spots.get_children()

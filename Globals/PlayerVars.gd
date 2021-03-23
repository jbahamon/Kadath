extends Node

var player_scene = preload("res://Characters/Arden/Arden.tscn")

var player: Player
var inventory: Inventory
var location_name = "CavernOfFlame"	
	
func load_save_data(save_data: SaveData):
	if player != null:
		player.queue_free()
		
	player = player_scene.instance()
	player.position = save_data.player_position
	location_name = save_data.location_name

	inventory = Inventory.new()
	inventory.load_save_data(save_data)

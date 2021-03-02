extends Node

var starting_position = Vector2(0, 0)
var starting_location_name = "CavernOfFlame"	
	
func load_save_data(save_data: SaveData):
	self.starting_position = save_data.player_position
	self.starting_location_name = save_data.location

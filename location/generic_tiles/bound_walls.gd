tool
extends TileSet

var floor_tile = find_tile_by_name("floor")
var wall_tile = find_tile_by_name("wall")

func _is_tile_bound(drawn_id, neighbor_id):
	return (drawn_id == neighbor_id) or \
	(drawn_id == wall_tile and neighbor_id == -1)

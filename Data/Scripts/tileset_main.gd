tool
extends TileSet

const GRASS = 0
const BRICK = 1
const HGRASS = 2
const HBRICK = 3

var binds = {
	GRASS : [BRICK],
	GRASS : [HGRASS],
	BRICK : [HBRICK]
}

func _is_tile_bound(drawn_id, neighbor_id):
	if drawn_id in binds:
		return neighbor_id in binds[drawn_id]

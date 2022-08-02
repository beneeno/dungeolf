tool
extends TileSet

const GRASS = 0
const BRICK = 1
const HGRASS = 2
const HBRICK = 3

var binds = {
	GRASS: [BRICK, HGRASS],
	BRICK: [HBRICK]
}

func _is_tile_bound(id, nid):
	return nid in binds[id]

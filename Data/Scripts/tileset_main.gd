tool
extends TileSet

const ROCK = 0
const BRICK = 1
const BORDER = 2

var binds = {
	ROCK: [BORDER]
}

func _is_tile_bound(id, nid):
	if id in binds:
		return nid in binds[id]

tool
extends TileSet

const ROCK = 0
const BRICK = 1
const BORDER = 2

var binds = {
	"tile_rock": ["border", "tile_mud"],
	"tile_mud": ["border", "tile_rock"]
}

func _is_tile_bound(id, nid):
	var idn = tile_get_name(id)
	if idn in binds:
		if nid != -1:
			print(nid)
			return tile_get_name(nid) in binds[idn]

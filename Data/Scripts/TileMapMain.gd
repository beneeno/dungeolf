extends TileMap

const GRASS = 0
const BRICK = 1
const HGRASS = 2
const HBRICK = 3

const bounciness = {
	GRASS: 0.5,
	BRICK: 0.8
}
const roughness = {
	GRASS: 0.01,
	BRICK: 0.01
}

export var Tile : PackedScene
export var Hole : PackedScene

var t

func _ready():
	var tiles = get_used_cells()
	for i in tiles.size():
		var pos = map_to_world(tiles[i]) + Vector2(5, 5)
		var id = get_cell(tiles[i].x, tiles[i].y)
		
		# Instance based on tile id
		match id:
			GRASS, BRICK:
				t = Tile.instance()
				t.init(bounciness[id], roughness[id])
			HGRASS, HBRICK:
				t = Hole.instance()
		
		t.position = pos
		get_parent().call_deferred("add_child", t)

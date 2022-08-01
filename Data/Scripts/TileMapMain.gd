extends TileMap

const GRASS = 0
const BRICK = 1

const bounciness = {
	GRASS: 0.5,
	BRICK: 0.8
}
const roughness = {
	GRASS: 0.01,
	BRICK: 0.01
}

export var Tile: PackedScene

func _ready():
	print(bounciness)
	var tiles = get_used_cells()
	for i in tiles.size():
		var pos = map_to_world(tiles[i])
		var id = get_cell(tiles[i].x, tiles[i].y)
		
		# Instance based on tile id
		match id:
			GRASS, BRICK:
				var t = Tile.instance()
				t.init(bounciness[id], roughness[id])
				t.position = pos + Vector2(5, 5)
				get_parent().call_deferred("add_child", t)

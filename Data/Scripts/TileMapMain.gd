extends TileMap

const ROCK = 0
const BRICK = 1

const bounciness = {
	ROCK: 0.5,
	BRICK: 0.8
}
const roughness = {
	ROCK: 0.01,
	BRICK: 0.01
}

export var Tile : PackedScene
export var Hole : PackedScene

var t


func _ready():
	var tiles = get_used_cells()
	for i in tiles.size():
		var pos = map_to_world(tiles[i]) + Vector2(6, 6)
		var id = get_cell(tiles[i].x, tiles[i].y)
		
		if id != 2:
			# Instance based on tile id
			match id:
				ROCK, BRICK:
					t = Tile.instance()
					t.init(bounciness[id], roughness[id])
	#			hole1, hole2:
	#				t = Hole.instance()
			
			t.position = pos
			get_parent().call_deferred("add_child", t)
		else:
			# Delete border
			set_cellv(tiles[i], -1)

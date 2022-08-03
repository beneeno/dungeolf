extends TileMap

const ROCK = 0
const BRICK = 1
const BORDER = 2

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
		var id = get_cellv(tiles[i])
		
		# Instance based on tile id
		if id != BORDER:
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
		
		# Fix holes (dude wtf is this shit, why am i doing this)
		if id == ROCK:
			for adjacent in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
				if not get_cellv(tiles[i] + adjacent) in [-1, ROCK, BORDER]:
					var fixpos = tiles[i] * 6
					match adjacent:
						Vector2.LEFT:
							$FixHoles.set_cell(fixpos.x, fixpos.y, 0)
							$FixHoles.set_cell(fixpos.x, fixpos.y+5, 0)
						Vector2.RIGHT:
							$FixHoles.set_cell(fixpos.x+5, fixpos.y, 0)
							$FixHoles.set_cell(fixpos.x+5, fixpos.y+5, 0)
						Vector2.UP:
							$FixHoles.set_cell(fixpos.x, fixpos.y, 0)
							$FixHoles.set_cell(fixpos.x+5, fixpos.y, 0)
						Vector2.DOWN:
							$FixHoles.set_cell(fixpos.x, fixpos.y+5, 0)
							$FixHoles.set_cell(fixpos.x+5, fixpos.y+5, 0)

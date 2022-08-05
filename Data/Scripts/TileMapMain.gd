extends TileMap

const BOUNCINESS = {
	"tile_rock": 0.5,
	"tile_brick": 0.8
}
const ROUGHNESS = {
	"tile_rock": 0.01,
	"tile_brick": 0.01
}

const FIX_HOLES = [
	"tile_brick"
]

export var Tile : PackedScene
export var Start : PackedScene
export var Goal : PackedScene


func _ready():
	var tiles = get_used_cells()
	for i in tiles.size():
		var pos = map_to_world(tiles[i]) + Vector2(6, 6)
		var tile_name = tile_set.tile_get_name(get_cellv(tiles[i]))
		
		# Instance based on tile id
		if tile_name != "border":
			var t
			match tile_name:
				"tile_rock", "tile_brick":
					t = Tile.instance()
					t.init(BOUNCINESS[tile_name], ROUGHNESS[tile_name])
				"start":
					t = Start.instance()
					pos += Vector2(6, 6)
					set_cellv(tiles[i], -1)
				"goal_all", "goal_right", "goal_left", "goal_down", "goal_up":
					t = Goal.instance()
					pos += Vector2(6, 6)
					set_cellv(tiles[i], -1)
			
			if t != null:
				t.position = pos
				get_parent().call_deferred("add_child", t)
		else:
			# Delete border
			set_cellv(tiles[i], -1)
		
		# Fix holes (dude wtf is this shit, why am i doing this)
		# Ben, in case you need to change this- you might need to change the grid size
		# of the "FixHoles" tilemap in the TileMapMain scene. But trust me, and DONT CHANGE IT.
		# JUST PICK ONE FREAKIN ART STYLE DUDE, STOP CHANGING IT EVERY FEW DAYS. JESUS CHRIST
		if tile_name == "tile_rock":
			for adjacent in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
				if get_cellv(tiles[i] + adjacent) != -1:
					if tile_set.tile_get_name(get_cellv(tiles[i] + adjacent)) in FIX_HOLES:
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

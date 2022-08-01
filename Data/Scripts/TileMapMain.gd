extends TileMap

export var Block: PackedScene

func _ready():
	var blocks = get_used_cells()
	for i in range(0, blocks.size()):
		var pos = map_to_world(blocks[i])
		var b = Block.instance()
		var id = get_cell(blocks[i].x, blocks[i].y)
		b.init(id)
		b.position = pos + Vector2(5,5)
		get_parent().call_deferred("add_child", b)

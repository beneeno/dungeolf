extends Node2D

export var Ball : PackedScene

func _ready():
	var b = Ball.instance()
	b.position = position
	get_parent().call_deferred("add_child", b)

extends Node2D

export var Ball : PackedScene

func _ready():
	if get_parent().name == "Level":
		get_node("../Camera2D").global_position = global_position
		get_node("../CamTarget").global_position = global_position
		get_parent().switch_camera(self)

func _on_Timer_timeout():
	if get_parent().name == "Level":
		var b = Ball.instance()
		b.position = position
		get_parent().call_deferred("add_child", b)

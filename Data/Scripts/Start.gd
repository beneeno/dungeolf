extends Node2D

export var Ball : PackedScene

func _ready():
	if get_parent().name == "Level":
		get_node("../Camera2D").global_position = global_position
		get_node("../CamTarget").global_position = global_position
		get_parent().switch_camera(self)

func _physics_process(_delta):
	if has_node("../Ball"):
		var ball = get_node("../Ball")
		if ball.position.round() == position.round():
			ball.z_index = 0

func _on_Timer_timeout():
	if get_parent().name == "Level":
		var b = Ball.instance()
		b.position.x = position.x
		b.position.y  = position.y - 8
		b.z_index = -1
		get_parent().call_deferred("add_child", b)

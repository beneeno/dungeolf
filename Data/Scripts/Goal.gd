extends Node2D

var _ball_in_area = false
var _win = false

onready var area = $Sprite/Area2D

func _ready():
	pass
	
func _physics_process(_delta):
	if _ball_in_area:
		if position.distance_to(get_node("../Ball").position) < 3:
#			get_parent().level_complete()
			get_node("../Ball").z_index = -1
			_win = true

func _on_Area2D_body_entered(body):
	if body.get_name() == "Ball":
		_ball_in_area = true

func _on_Area2D_body_exited(body):
	if body.get_name() == "Ball":
		_ball_in_area = false
		
		if _win == true:
			get_node("../Ball").queue_free()

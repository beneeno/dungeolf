extends Node2D

func _ready():
	pass

func _on_Area2D_body_entered(body):
	body.global_position = global_position
	if body.get_name() == "Ball":
		get_parent().level_complete()

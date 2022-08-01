extends Node2D

func _on_Area2D_body_entered(body):
	body.global_position = global_position
	if body.get("velocity"):
		body.velocity.x = 0

extends Area2D


func _ready():
	pass


func _on_Spikes_body_entered(body):
	if body.get_name() == "Ball":
		get_parent().switch_camera(get_parent())
		body.die()
		get_parent().level_failed()

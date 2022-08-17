extends ColorRect

signal transition_out_done
signal transition_in_done

onready var anim_player = $AnimationPlayer

func transition_out():
	anim_player.play("transition_out")

func transition_in():
	anim_player.play("transition_in")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "transition_out":
		emit_signal("transition_out_done")
	elif anim_name == "transition_in":
		emit_signal("transition_in_done")

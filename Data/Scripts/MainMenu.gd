extends Control

func _ready():
	pass

func _on_PlayButton_pressed():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("Levels_Open")

func _on_OptionsButton_pressed():
	pass # Replace with function body.

func _on_QuitButton_pressed():
	if not $AnimationPlayer.is_playing():
		get_tree().quit()

func _on_LevelsBackButton_pressed():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("Levels_Close")

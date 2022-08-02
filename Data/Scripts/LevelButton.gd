extends Button

var level_path

func _init():
	pass

func _on_LevelButton_pressed():
	var error = get_tree().change_scene(level_path)
	if error != OK:
		push_error(str(error))

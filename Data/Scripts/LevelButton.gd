extends Button

var level_path

func _init():
	pass

func _on_LevelButton_pressed():
	get_tree().change_scene(level_path)

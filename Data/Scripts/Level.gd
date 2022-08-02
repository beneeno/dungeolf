extends Node2D

var next_level_path

func _ready():
	var file = File.new()
	if file.file_exists("res://Data/Scenes/Levels/Level" + str(int(filename) + 1) + ".tscn"):	
		next_level_path = "res://Data/Scenes/Levels/Level" + str(int(filename) + 1) + ".tscn"
	else:
		next_level_path = "res://Data/Scenes/UI/MainMenu.tscn"

func level_complete():
	var error = get_tree().change_scene(next_level_path)
	if error != OK:
		push_error(str(error))

func _on_MenuButton_pressed():
	var error = get_tree().change_scene("res://Data/Scenes/UI/MainMenu.tscn")
	if error != OK:
		push_error(str(error))

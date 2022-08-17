extends Control

var levels = LevelNames.dict
var Level = preload("res://Data/Scenes/UI/LevelButton.tscn")
var next_level
var quit_pressed = false

onready var transition = $Transition

func _ready():
	transition.transition_in()
	# Create level list, use autoloaded LevelNames dictionary for names
	for i in levels:
		var name = levels[i]
		var l = Level.instance()
		l.add_to_group("Buttons")
		l.text = ("Level " + str(i) + ": " + name)
		l.level_path = ("res://Data/Scenes/Levels/Level" + str(i) + ".tscn")
		$Levels/VBoxContainer.add_child(l)

func _on_PlayButton_pressed():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("Levels_Open")

func _on_QuitButton_pressed():
	if not $AnimationPlayer.is_playing():
		quit_pressed = true
		transition.transition_out()

func _on_LevelsBackButton_pressed():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("Levels_Close")

func _next_level(level_path):
	next_level = level_path
	transition.transition_out()

func _on_Transition_transition_out_done():
	if quit_pressed == true:
		get_tree().quit()
	else:
		var error = get_tree().change_scene(next_level)
		if error != OK:
			push_error(str(error))

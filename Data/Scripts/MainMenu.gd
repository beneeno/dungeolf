extends Control

var levels = LevelNames.dict
var Level = preload("res://Data/Scenes/UI/LevelButton.tscn")

var options = 0

func _ready():
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

func _on_OptionsButton_pressed():
	options += 1
	if options == 10:
		$Label.visible = true

func _on_QuitButton_pressed():
	if not $AnimationPlayer.is_playing():
		get_tree().quit()

func _on_LevelsBackButton_pressed():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("Levels_Close")

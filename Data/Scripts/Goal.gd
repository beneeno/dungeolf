extends Node2D

var _ball_in_area = false
var _win = false

onready var area = $Sprite/Area2D
onready var Sound = $AudioStreamPlayer

onready var snd_win = preload("res://Assets/Sounds/win.wav")

func _ready():
	pass
	
func _physics_process(_delta):
	if _ball_in_area:
		if position.distance_to(get_node("../Ball").position) < 3:
			$Timer.start()
			get_node("../Ball").z_index = -1
			_win = true

func _on_Area2D_body_entered(body):
	if body.get_name() == "Ball":
		_ball_in_area = true

func _on_Area2D_body_exited(body):
	if body.get_name() == "Ball":
		_ball_in_area = false
		
		if _win == true:
			get_parent().switch_camera(get_parent())
			get_node("../Ball").queue_free()
			_play_sound(snd_win)

func _on_Timer_timeout():
	get_parent().level_complete()

func _play_sound(wav):
	if Sound.stream == wav:
		if Sound.playing == false:
			Sound.stream = wav
			Sound.play()
	else:
		Sound.stream = wav
		Sound.play()


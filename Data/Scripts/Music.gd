extends AudioStreamPlayer

var mute = false

func _process(_delta):
	if mute == false:
		if playing == false:
			playing = true
	else:
		playing = false

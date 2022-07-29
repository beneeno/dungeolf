extends StaticBody2D

var bounciness
var roughness

func _ready():
	pass

func init(id):
	# Set traits
	match id:
		0: # Normal
			bounciness = 0.5
			roughness = 0.01
		1: # Bouncy
			bounciness = 0.8
			roughness = 0.01
		2: # Rough
			bounciness = 0.25
			roughness = 0.1

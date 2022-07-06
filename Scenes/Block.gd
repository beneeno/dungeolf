extends Polygon2D

export(String, "Normal", "Bouncy", "Rough") var Type = 'Normal'

var bounce
var friction

func _ready():
	var collision_shape = CollisionPolygon2D.new()
	collision_shape.polygon = polygon
	$StaticBody2D.add_child(collision_shape)
	
	# Set traits
	match Type:
		"Normal":
			bounce = 0.5
			friction = 0.008
		"Bouncy":
			bounce = 0.8
			friction = 0.008
		"Rough":
			bounce = 0.25
			friction = 0.1

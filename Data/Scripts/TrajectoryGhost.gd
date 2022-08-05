extends KinematicBody2D

onready var Ball = get_node("../..")
onready var _t_grav = Ball.gravity
onready var _t_pow = Ball.power
onready var _t_vel = -get_node("../Aim").position * _t_pow
onready var Line = get_node("../TrajectoryLine")

func _ready():
	Line.clear_points()

func _physics_process(delta):
	for i in 120:
		if global_position.distance_to(get_node("/root/Level/Goal").global_position) > 3:
			_motion(delta)
		if Line.get_point_count() < 180:
			Line.add_point(position)
	

func _motion(delta):
	# Motion and velocity code
	_t_vel.y += _t_grav * delta
	var collision = move_and_collide(_t_vel * delta)
	
	# Bounce physics
	if collision:
		var angle = collision.normal.dot(_t_vel.normalized())
		var bounce = collision.collider.bounciness
		var friction = collision.collider.roughness
		if collision.normal.round() == Vector2.UP:
			if angle < -0.2: # If angled enough to bounce, keep x speed
				_t_vel = _t_vel.bounce(collision.normal) * bounce
				_t_vel.x *= 4 / (5 * bounce)
			else: # Parallel to floor, and rolling. No bounce
				_t_vel.y = 0
				_t_vel.x = lerp(_t_vel.x, 0, friction)
		else: # If collision is NOT the floor, always bounce
			_t_vel = _t_vel.bounce(collision.normal) * bounce
	
	# Motion limits
	if abs(_t_vel.x) < 2:
		_t_vel.x = 0
	if collision and abs(_t_vel.y) < 2 and collision.normal.round() == Vector2.UP:
		_t_vel.y = 0
		_t_vel.y = clamp(_t_vel.y, -350, 350)
	
	# Stuck fixes
	if collision and collision.normal.round() != Vector2.UP and _t_vel.x == 0:
		_t_vel.x += 5 * collision.normal.round().x
	if _t_vel.y == 0:
		position.y = round(position.y)

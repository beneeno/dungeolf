extends KinematicBody2D
var velocity = Vector2()
var gravity = 350
var max_speed = 350
var friction = 0.01
var power = 5

var _new_pos = Vector2()
var _line_position = Vector2()
var _is_moving = false
var _is_aiming = false
var _mouse_on_ball = false

onready var Ghost = load("res://Scenes/TrajectoryGhost.tscn")
onready var Trail = $CPUParticles2D

func _ready():
	pass

func _process(delta):
	_draw_aim_line()
	_draw_particles()
	
	#PRINT DEBUG#
	print(velocity.y)
	#############

func _physics_process(delta):
	_movement(delta)
	_draw_trajectory()


### MOVEMENT FUNCTION
func _movement(delta):
	velocity.y += gravity * delta
	var motion = move_and_slide(velocity, Vector2.UP, false, 1)
	
	# Collision code
	if get_slide_count() > 0:
		var collision = get_slide_collision(0)
		velocity = velocity.bounce(collision.normal) * 0.5


### INPUT FUNCTIONS
func _on_ClickableZone_mouse_entered():
	_mouse_on_ball = true

func _on_ClickableZone_mouse_exited():
	_mouse_on_ball = false

func _input(event):
	# Start aim
	if Input.is_action_just_pressed("lmb") and _mouse_on_ball:
		_is_aiming = true
	
	if _is_aiming:
		# Cancel shot
		if ((Input.is_action_just_released("lmb") and _mouse_on_ball)
		or Input.is_action_just_pressed("rmb")):
			_is_aiming = false
		# Shoot ball
		if Input.is_action_just_released("lmb") and !_mouse_on_ball:
			_shoot()

func _shoot():
	var aim_point = $Launcher/Aim.position.round()
	velocity = -aim_point * power
	_line_position = $Launcher/TrajectoryLine.global_position
	_is_aiming = false


### DRAW FUNCTIONS
func _draw_trajectory():
	if _is_aiming:
		if !has_node("Launcher/TrajectoryGhost"):
			var g = Ghost.instance()
			$Launcher.add_child(g)
		elif _new_pos != $Launcher/Aim.position:
			$Launcher/TrajectoryGhost.queue_free()
	elif has_node("Launcher/TrajectoryGhost"):
		$Launcher/TrajectoryGhost.queue_free()
	else:
		_clear_trajectory()
	_new_pos = $Launcher/Aim.position

func _clear_trajectory():
	if $Launcher/TrajectoryLine.get_point_count() > 0:
		if _is_moving == true:
			$Launcher/TrajectoryLine.global_position = _line_position
			var point = 0
			$Launcher/TrajectoryLine.remove_point(point)
			point += 1
		else:
			for i in 8:
				var point = $Launcher/TrajectoryLine.get_point_count()
				$Launcher/TrajectoryLine.remove_point(point-1)
				point -= 1
	else:
		$Launcher/TrajectoryLine.position = Vector2(0, 0)

func _draw_particles():
	var speed = abs(velocity.x) + abs(velocity.y)
	if speed > 200:
		Trail.emitting = true
	else:
		Trail.emitting = false

func _draw_aim_line():
	$Launcher/PowerLine.set_point_position(1, $Launcher/Aim.position)
	if _is_aiming:
		$Launcher/Aim.position = get_local_mouse_position().clamped(50)
	else:
		$Launcher/Aim.position = Vector2(0,0)

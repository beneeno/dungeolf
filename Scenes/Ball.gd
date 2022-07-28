extends KinematicBody2D
var velocity = Vector2()
var gravity = 400
var power = 10

var _cam_lastpos = Vector2()
var _new_pos = Vector2()
var _line_position = Vector2()
var _is_aiming = false
var _is_panning = false
var _mouse_on_ball = false

onready var Ghost = load("res://Scenes/TrajectoryGhost.tscn")
onready var Line = $Launcher/TrajectoryLine
onready var Trail = $CPUParticles2D
onready var Aim = $Launcher/Aim
onready var _vp = get_viewport_rect().size / 2
onready var _limits = get_node("../TileMapMain").get_used_rect()
onready var _cell = get_node("../TileMapMain").cell_size
onready var _tiles = Rect2(_limits.position * _cell, (_limits.position * _cell) + (_limits.size * _cell))
onready var _tiles_mid = (_limits.position * _cell) + ((_limits.size * _cell) / 2)
onready var _cam_left = _tiles.position.x + _vp.x - 20
onready var _cam_right = _tiles.size.x - _vp.x + 20
onready var _cam_up = _tiles.position.y + _vp.y - 20
onready var _cam_down = _tiles.size.y - _vp.y + 20

func _ready():
	pass

func _process(_delta):
	_draw_aim_line()
	_draw_particles()
	_camera()

func _physics_process(delta):
	_motion(delta)
	_draw_trajectory()


### MOTION FUNCTIONS
func _motion(delta):
	# Motion and velocity code
	velocity.y += gravity * delta
	var collision = move_and_collide(velocity * delta)
	
	# Bounce physics
	if collision and collision.collider is StaticBody2D:
		var angle = collision.normal.dot(velocity.normalized())
		var bounce = collision.collider.bounciness
		var friction = collision.collider.roughness
		if collision.normal.round() == Vector2.UP:
			if angle < -0.2: # If angled enough to bounce, keep x speed
				velocity = velocity.bounce(collision.normal) * bounce
				velocity.x *= 1.5
			else: # Parallel to floor, and rolling. No bounce
				velocity.y = 0
				velocity.x = lerp(velocity.x, 0, friction)
		else: # If collision is NOT the floor, always bounce
			velocity = velocity.bounce(collision.normal) * bounce
	
	# Motion limits
	if abs(velocity.x) < 2:
		velocity.x = 0
	if collision and abs(velocity.y) < 2 and collision.normal.round() == Vector2.UP:
		velocity.y = 0
	velocity.y = clamp(velocity.y, -350, 350)
	
	# Stuck fixes
	if collision and collision.normal.round() != Vector2.UP and velocity.x == 0:
		velocity.x += 5 * collision.normal.round().x
	if velocity.y == 0:
		position.y = round(position.y)

func _shoot():
	for i in 4:
		yield(get_tree(), "physics_frame")
	var aim_point = Aim.position
	velocity = -aim_point * power
	_line_position = Line.global_position
	_is_aiming = false


### INPUT FUNCTIONS
func _on_ClickableZone_mouse_entered():
	_mouse_on_ball = true

func _on_ClickableZone_mouse_exited():
	_mouse_on_ball = false

func _input(event):
	# Start aim or start panning
	if Input.is_action_just_pressed("lmb"):
		if _mouse_on_ball and velocity == Vector2.ZERO:
			_is_aiming = true
		if !_mouse_on_ball:
			_is_panning = true
	
	# Stop aiming, shoot, or stop panning
	if Input.is_action_just_released("lmb"):
		if _is_aiming:
			if _mouse_on_ball:
				_is_aiming = false
			else:
				_shoot()
		elif _is_panning:
			_is_panning = false
			
	
	# Stop aiming, or focus ball/goal
	if Input.is_action_just_pressed("rmb"):
		if _is_aiming:
			_is_aiming = false
		elif !_is_panning:
			$CamTarget.global_position = global_position
	
	if event is InputEventMouseMotion:
		if _is_panning:
			$CamTarget.position -= event.relative


### DRAWING FUNCTIONS
func _draw_particles():
	var speed = abs(velocity.x) + abs(velocity.y)
	if speed > 200:
		Trail.emitting = true
	else:
		Trail.emitting = false

func _draw_aim_line():
	$Launcher/PowerLine.set_point_position(1, Aim.position)
	if _is_aiming:
		Aim.position = get_local_mouse_position().clamped(32)
	else:
		Aim.position = Vector2(0,0)

func _draw_trajectory():
	if _is_aiming:
		if !has_node("Launcher/TrajectoryGhost"):
			var g = Ghost.instance()
			$Launcher.add_child(g)
		elif _new_pos != Aim.position:
			$Launcher/TrajectoryGhost.queue_free()
	elif has_node("Launcher/TrajectoryGhost"):
		$Launcher/TrajectoryGhost.queue_free()
	else:
		_clear_trajectory()
	_new_pos = Aim.position

func _clear_trajectory():
	if Line.get_point_count() > 8:
		if velocity != Vector2.ZERO:
			Line.global_position = _line_position
			var point = 0
			Line.remove_point(point)
			point += 1
		else:
			for i in 8:
				var point = Line.get_point_count()
				Line.remove_point(point-1)
	else:
		Line.position = Vector2(0, 0)
		Line.clear_points()

func _camera():
	# Custom drag margins, ugh
	if $CamTarget.global_position.x == $Camera2D.global_position.x:
		# If going left
		if velocity.x < 0 and $Camera2D.position.x < 128:
			$CamTarget.global_position.x = _cam_lastpos.x
			$Camera2D.global_position.x = _cam_lastpos.x
		# If going right
		if velocity.x > 0 and $Camera2D.position.x > -128:
			$CamTarget.global_position.x = _cam_lastpos.x
			$Camera2D.global_position.x = _cam_lastpos.x
		
	if $CamTarget.global_position.y == $Camera2D.global_position.y:
		# If going down
		if velocity.y > 0 and $Camera2D.position.y > -76:
			$CamTarget.global_position.y = _cam_lastpos.y
			$Camera2D.global_position.y = _cam_lastpos.y
		# If going up
		if velocity.y < 0 and $Camera2D.position.y < 76:
			$CamTarget.global_position.y = _cam_lastpos.y
			$Camera2D.global_position.y = _cam_lastpos.y
	
	# Lerp and round
	$Camera2D.position = lerp($Camera2D.position, $CamTarget.position, 0.2)
	if $Camera2D.position.distance_to($CamTarget.position) < 1:
		$Camera2D.position = $CamTarget.position

	# Keep camera in boundary
	if (_cam_right - _cam_left) > 0:
		$CamTarget.global_position.x = clamp($CamTarget.global_position.x, _cam_left, _cam_right)
		$Camera2D.global_position.x = clamp($Camera2D.global_position.x, _cam_left, _cam_right)
	else:
		$CamTarget.global_position.x = _tiles_mid.x
		$Camera2D.global_position.x = _tiles_mid.x
	if (_cam_down - _cam_up) > 0:
		$CamTarget.global_position.y = clamp($CamTarget.global_position.y, _cam_up, _cam_down)
		$Camera2D.global_position.y = clamp($Camera2D.global_position.y, _cam_up, _cam_down)
	else:
		$CamTarget.global_position.y = _tiles_mid.y
		$Camera2D.global_position.y = _tiles_mid.y
	
	_cam_lastpos = $Camera2D.global_position

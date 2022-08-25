extends KinematicBody2D

export var TrajGhost: PackedScene

var velocity = Vector2()
var gravity = 400
var power = 6
var mouse_on_ball = false
var is_aiming = false
var is_dead = false

var _new_pos = Vector2()
var _line_position = Vector2()
var _can_sound_collide = true
var _sound_collide_id = 1

onready var Line = $Launcher/TrajectoryLine
onready var Trail = $CPUParticles2D
onready var Aim = $Launcher/Aim
onready var Sound = $AudioStreamPlayer

onready var snd_aim = preload("res://Assets/Sounds/aim.wav")
onready var snd_shoot = preload("res://Assets/Sounds/shoot.wav")
onready var snd_collide1 = preload("res://Assets/Sounds/collide1.wav")
onready var snd_collide2 = preload("res://Assets/Sounds/collide2.wav")
onready var snd_collide3 = preload("res://Assets/Sounds/collide3.wav")
onready var snd_bounce1 = preload("res://Assets/Sounds/bounce1.wav")
onready var snd_bounce2 = preload("res://Assets/Sounds/bounce2.wav")
onready var snd_bounce3 = preload("res://Assets/Sounds/bounce3.wav")
onready var snd_die = preload("res://Assets/Sounds/die.wav")

func _ready():
	if get_parent().name == "Level":
		get_parent().switch_camera(self)

func _process(_delta):
	_speed_particles()
	
	# Check if out of shots, fail level
	if velocity == Vector2.ZERO and get_parent().Shots <= 0:
		get_parent().level_failed()

func _physics_process(delta):
	if is_dead == false:
		_motion(delta)
	_draw_trajectory()
	_draw_aim_line()

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
				velocity.x *= 4 / (5 * bounce)
			else: # Parallel to floor, and rolling. No bounce
				velocity.y = 0
				velocity.x = lerp(velocity.x, 0, friction)
		else: # If collision is NOT the floor, always bounce
			velocity = velocity.bounce(collision.normal) * bounce
	
		# Throttle power when on mud
		if collision.collider.roughness == 0.1:
			power = 3.2
		else:
			power = 6
	
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
	
	# Bounce / Collide Sound
	if collision:
		if _can_sound_collide == true and (abs(velocity.y) > 60 or abs(velocity.x) > 60):
			var collide_sound
			if collision.collider.bounciness == 0.8:
				match _sound_collide_id:
					1:
						collide_sound = snd_bounce1
					2:
						collide_sound = snd_bounce2
					3:
						collide_sound = snd_bounce3
			else:
				match _sound_collide_id:
					1:
						collide_sound = snd_collide1
					2:
						collide_sound = snd_collide2
					3:
						collide_sound = snd_collide3
			_play_sound(collide_sound)
			_sound_collide_id += 1
			if _sound_collide_id == 4:
				_sound_collide_id = 1
			_can_sound_collide = false
	else:
		_can_sound_collide = true

func _shoot():
	for i in 4:
		yield(get_tree(), "physics_frame")
	if velocity == Vector2.ZERO:
		get_parent().Shots -= 1
	var aim_point = Aim.position
	velocity = -aim_point * power
	_line_position = Line.global_position
	is_aiming = false
	_play_sound(snd_shoot)


### INPUT FUNCTIONS
func _on_ClickableZone_mouse_entered():
	mouse_on_ball = true

func _on_ClickableZone_mouse_exited():
	mouse_on_ball = false

func _input(event):
	if is_dead == false and get_parent().Shots > 0:
		# Start aim
		if Input.is_action_just_pressed("lmb"):
			if mouse_on_ball and velocity == Vector2.ZERO:
				is_aiming = true
		
		# Stop aiming or shoot
		if Input.is_action_just_released("lmb"):
			if is_aiming:
				if mouse_on_ball:
					is_aiming = false
				else:
					_shoot()
		
		# Stop aiming, or focus ball/goal
		if Input.is_action_just_pressed("rmb"):
			if is_aiming:
				is_aiming = false
		
		if event is InputEventMouseMotion:
			if is_aiming:
				_play_sound(snd_aim)


### DRAWING FUNCTIONS
func _speed_particles():
	var speed = abs(velocity.x) + abs(velocity.y)
	if speed > 200:
		Trail.emitting = true
	else:
		Trail.emitting = false

func _draw_aim_line():
	$Launcher/PowerLine.set_point_position(1, Aim.position)
	if is_aiming:
		Aim.position = get_local_mouse_position().clamped(48)
	else:
		Aim.position = Vector2(0,0)

func _draw_trajectory():
	if is_aiming:
		if !has_node("Launcher/TrajectoryGhost"):
			var g = TrajGhost.instance()
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

func die():
	is_dead = true
	velocity = Vector2.ZERO
	_play_sound(snd_die)


## AUDIO

func _play_sound(wav):
	if Sound.stream == wav:
		if Sound.playing == false:
			Sound.stream = wav
			Sound.play()
	else:
		Sound.stream = wav
		Sound.play()
		

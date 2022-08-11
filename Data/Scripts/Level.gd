extends Node2D

export var CamPath : NodePath
export var CamTargetPath : NodePath

var next_level_path
var _cam_lastpos = Vector2()
var _is_panning = false
var _limits = Rect2()
var _cell = Vector2()
var _tiles = Rect2()
var _tiles_mid = Vector2()
var _cam_left = int()
var _cam_right = int()
var _cam_up = int()
var _cam_down = int()

onready var _vp = get_viewport_rect().size / 2

func _ready():
	# Load next level
	var file = File.new()
	if file.file_exists("res://Data/Scenes/Levels/Level" + str(int(filename) + 1) + ".tscn"):
		next_level_path = "res://Data/Scenes/Levels/Level" + str(int(filename) + 1) + ".tscn"
	else:
		next_level_path = "res://Data/Scenes/UI/MainMenu.tscn"
	
	_cam_lastpos = global_position
	$CanvasLayer/MenuButton.visible = true
	
	# Check for tilemap and calculate camera limits
	var margin = 48
	_limits = $TileMapMain.get_used_rect()
	_cell = $TileMapMain.cell_size
	_tiles = Rect2(_limits.position * _cell, (_limits.position * _cell) + (_limits.size * _cell))
	_tiles_mid = (_limits.position * _cell) + ((_limits.size * _cell) / 2)
	_cam_left = _tiles.position.x + _vp.x - margin
	_cam_right = _tiles.size.x - _vp.x + margin
	_cam_up = _tiles.position.y + _vp.y - margin
	_cam_down = _tiles.size.y - _vp.y + margin

func _process(_delta):
	_camera()

func _input(event):
	# Reset camera position
	if Input.is_action_just_pressed("rmb"):
		if !_is_panning and has_node("Ball"):
			if get_node(CamPath).get_parent() != $Ball:
				get_node(CamTargetPath).global_position = $Ball.global_position
			switch_camera(get_node("Ball"))
	
	if Input.is_action_just_pressed("lmb"):
		if has_node("Ball"):
			if not $Ball.mouse_on_ball:
				_is_panning = true
		else:
			_is_panning = true

	if Input.is_action_just_released("lmb"):
		# Stop panning, and target the ball cam
		_is_panning = false
		if has_node("Ball"):
			if $Ball.is_aiming and not _is_panning:
				switch_camera(get_node("Ball")) 
	
	# Pan camera
	if event is InputEventMouseMotion:
		if _is_panning:
			get_node(CamTargetPath).position -= event.relative
			switch_camera(self)


func _camera():
	var Cam = get_node(CamPath)
	var CamTarget = get_node(CamTargetPath)
	
	if has_node("Ball"):
		if Cam.get_parent() == $Ball:
			# Custom drag margins, ugh
			if CamTarget.global_position.x == Cam.global_position.x:
				# If going left
				if $Ball.velocity.x < 0 and Cam.position.x < 128:
					CamTarget.global_position.x = _cam_lastpos.x
					Cam.global_position.x = _cam_lastpos.x
				# If going right
				if $Ball.velocity.x > 0 and Cam.position.x > -128:
					CamTarget.global_position.x = _cam_lastpos.x
					Cam.global_position.x = _cam_lastpos.x
			if CamTarget.global_position.y == Cam.global_position.y:
				# If going down
				if $Ball.velocity.y > 0 and Cam.position.y > -76:
					CamTarget.global_position.y = _cam_lastpos.y
					Cam.global_position.y = _cam_lastpos.y
				# If going up
				if $Ball.velocity.y < 0 and Cam.position.y < 76:
					CamTarget.global_position.y = _cam_lastpos.y
					Cam.global_position.y = _cam_lastpos.y
		
	# Lerp and round
	Cam.position = lerp(Cam.position, CamTarget.position, 0.15)
	if Cam.position.distance_to(CamTarget.position) < 1:
		Cam.position = CamTarget.position

	# Keep camera in boundary
	if (_cam_right - _cam_left) > 0:
		CamTarget.global_position.x = clamp(CamTarget.global_position.x, _cam_left, _cam_right)
		Cam.global_position.x = clamp(Cam.global_position.x, _cam_left, _cam_right)
	else:
		CamTarget.global_position.x = _tiles_mid.x
		Cam.global_position.x = _tiles_mid.x
	if (_cam_down - _cam_up) > 0:
		CamTarget.global_position.y = clamp(CamTarget.global_position.y, _cam_up, _cam_down)
		Cam.global_position.y = clamp(Cam.global_position.y, _cam_up, _cam_down)
	else:
		CamTarget.global_position.y = _tiles_mid.y
		Cam.global_position.y = _tiles_mid.y
	
	_cam_lastpos = Cam.global_position

func switch_camera(target):
	var c = get_node(CamPath)
	var t = get_node(CamTargetPath)
	var cpos = c.global_position
	var tpos = t.global_position
	
	if target != c.get_parent():
		c.get_parent().remove_child(c)
		t.get_parent().remove_child(t)
		target.add_child(c)
		target.add_child(t)
		CamPath = c.get_path()
		CamTargetPath = t.get_path()
		c.global_position = cpos
		t.global_position = tpos

func level_complete():
	var error = get_tree().change_scene(next_level_path)
	if error != OK:
		push_error(str(error))

func level_failed():
	$CanvasLayer/RetryButton.visible = true

func _on_MenuButton_pressed():
	var error = get_tree().change_scene("res://Data/Scenes/UI/MainMenu.tscn")
	if error != OK:
		push_error(str(error))

func _on_RetryButton_pressed():
	var error = get_tree().reload_current_scene()
	if error != OK:
		push_error(str(error))

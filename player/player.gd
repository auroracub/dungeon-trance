
class_name Player extends Node3D

## references

@onready var dungeon := owner as Dungeon
@onready var center := %Center


## moving

enum SideMoveBehavior { StrafeOnly, StrafeAndTurn, TurnOnly, StrafeOnDodge, TurnOnDodge }

@export var side_move_behavior := SideMoveBehavior.StrafeOnDodge

@export var move_speed: float = 7.5 # per tile
var allow_skip_move_anim := true
var beat_on_move := true

var _move_tween : Tween
var _is_moving := false
@onready var _last_complete_move_position := position
@onready var _target_position := position


## turning

@export var turn_speed: float = 7.5 # per angle
var allow_skip_turn_anim := true
var beat_on_turn := false

var _turn_tween : Tween
var _is_turning := false
@onready var _last_complete_turn_yaw := rotation.y
@onready var _last_complete_turn_basis := transform.basis # used to avoid edge case from simultaneous turn + move
@onready var _target_rotation := rotation.y


## node

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	var _is_dodge_active = Input.is_action_pressed("dodge")
	
	# handle move input
	if Input.is_action_just_pressed("move_left"):
		var move_func := func(): _move_tile(Vector2i(-1, 0))
		var turn_func := func(): _turn_left()
		
		match side_move_behavior:
			SideMoveBehavior.StrafeOnly:
				move_func.call()
			SideMoveBehavior.StrafeAndTurn:
				move_func.call()
				turn_func.call()
			SideMoveBehavior.TurnOnly:
				turn_func.call()
			SideMoveBehavior.StrafeOnDodge:
				move_func.call() if _is_dodge_active else turn_func.call()
			SideMoveBehavior.TurnOnDodge:
				turn_func.call() if _is_dodge_active else move_func.call()
	elif Input.is_action_just_pressed("move_right"):
		var move_func := func(): _move_tile(Vector2i(+1, 0))
		var turn_func := func(): _turn_right()
		
		match side_move_behavior:
			SideMoveBehavior.StrafeOnly:
				move_func.call()
			SideMoveBehavior.StrafeAndTurn:
				move_func.call()
				turn_func.call()
			SideMoveBehavior.TurnOnly:
				turn_func.call()
			SideMoveBehavior.StrafeOnDodge:
				move_func.call() if _is_dodge_active else turn_func.call()
			SideMoveBehavior.TurnOnDodge:
				turn_func.call() if _is_dodge_active else move_func.call()
	elif Input.is_action_just_pressed("move_forward"):
		_move_tile(Vector2i(0, +1))
	elif Input.is_action_just_pressed("move_backward"):
		_move_tile(Vector2i(0, -1))
	
	# handle turn input
	if Input.is_action_just_pressed("look_left"):
		_turn_left()
	elif Input.is_action_just_pressed("look_right"):
		_turn_right()


## player

func _beat() -> void:
	if dungeon: dungeon.beat()


func _check_for_ground(relative_position: Vector3, margin: float = 0.1) -> bool:
	var check_origin = center.global_position
	var check_direction = relative_position.normalized()
	var check_target = check_origin + check_direction * relative_position.length()
	var query = PhysicsRayQueryParameters3D.create(check_origin, check_target + check_direction * margin)
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	
	if result:
		# wall hit
		return false
	else:
		var ground_distance = center.position.length() + margin
		check_origin = check_target
		check_direction = Vector3.DOWN
		check_target = check_origin + check_direction * ground_distance
		query = PhysicsRayQueryParameters3D.create(check_origin, check_target + check_direction * margin)
		result = space_state.intersect_ray(query)
		
		# ground hit
		return true if result else false


func _move(grid_offset: Vector2i, grid_interval: float = 1.0) -> void:
	if _is_moving:
		if !allow_skip_move_anim: return
		
		var difference = position.distance_to(_target_position)
		
		# complete rotation instantly
		_move_tween.kill()
		position = _target_position
		_last_complete_move_position = _target_position
		_is_moving = false
		
		if beat_on_move: _beat()
		
		# if the movement was nearly complete (based on this threshold) and skips are allowed,
		# start a new movement. otherwise, cancel.
		if difference > 0.2: return
	
	var tile_offset = (_last_complete_turn_basis.x * grid_offset.x * grid_interval) + (-_last_complete_turn_basis.z * grid_offset.y * grid_interval)
	
	if !_check_for_ground(tile_offset): return
	
	_is_moving = true
	
	var _original_position = position
	_target_position = _last_complete_move_position + tile_offset
	
	if _move_tween: _move_tween.kill()
	_move_tween = create_tween()
	_move_tween.set_ease(Tween.EASE_OUT).tween_method(func(alpha):
		position = lerp(_original_position, _target_position, alpha),
		0.0, 1.0, _original_position.distance_to(_target_position) / move_speed)
	
	await _move_tween.finished
	
	if beat_on_move: _beat()
	
	_last_complete_move_position = _target_position
	_is_moving = false


func _move_tile(direction: Vector2i) -> void:
	# # basic version
	# position += (transform.basis.x * direction.x) + (-transform.basis.z * direction.y)
	_move(direction, dungeon.tile_size if dungeon else 1.0)


func _turn(yaw_radians: float) -> void:
	if _is_turning:
		if !allow_skip_turn_anim: return
		
		var difference = abs(angle_difference(rotation.y, _target_rotation))
		
		# complete rotation instantly
		_turn_tween.kill()
		rotation.y = _target_rotation
		_last_complete_turn_yaw = _target_rotation
		_last_complete_turn_basis = transform.basis
		_is_turning = false
		
		if beat_on_turn: _beat()
		
		# if the rotation was nearly complete (based on this threshold) and skips are allowed,
		# start a new rotation. otherwise, cancel.
		if difference > deg_to_rad(20.0): return
	
	_is_turning = true
	
	var _original_rotation = rotation
	_target_rotation = _last_complete_turn_yaw - yaw_radians
	
	if _turn_tween: _turn_tween.kill()
	_turn_tween = create_tween()
	_turn_tween.set_ease(Tween.EASE_OUT).tween_method(func(alpha):
		rotation.y = lerp_angle(_original_rotation.y, _target_rotation, alpha),
		0.0, 1.0, abs(angle_difference(_original_rotation.y, _target_rotation)) / turn_speed)
	
	if beat_on_turn: _beat()
	
	await _turn_tween.finished
	
	_last_complete_turn_yaw = _target_rotation
	_last_complete_turn_basis = transform.basis
	_is_turning = false


func _turn_left() -> void:
	_turn(deg_to_rad(-90.0))


func _turn_right() -> void:
	_turn(deg_to_rad(+90.0))

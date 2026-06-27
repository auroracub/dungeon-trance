
class_name Player extends Node3D


@onready var dungeon := owner as Dungeon
@onready var pivot := %Pivot
@onready var center := %Center


## moving

@export_category("Movement")

enum SideMoveBehavior { StrafeOnDodge, TurnOnDodge, StrafeOnly, StrafeAndTurn, TurnOnly }
enum MovementSystem { WorldGrid, NodeLattice, MeshLattice }

@export var side_move_behavior := SideMoveBehavior.StrafeOnDodge

@export var move_speed: float = 7.5 # per tile
var _max_step_height := 0.25
var _max_floor_angle := 20.0
var allow_skip_move_anim := true
var beat_on_move := true
var beat_on_collide := true
var beat_on_move_changes_bpm := true

var _move_tween : Tween
var _is_moving := false
@onready var _target_position := position
@onready var _target_basis := basis
@onready var _last_complete_move_position := position

# NOTE: this could all be abstracted if necessary, but it's mainly for gameplay testing/prototyping
var _movement_system := MovementSystem.WorldGrid
var facing_direction := Global.Direction2D.Up
var _target_facing_direction := facing_direction
var _snap_to_lattice := true

# move_world_grid

@export var world_grid_scale := 2.0

# move_node_lattice

@export_group("Node Lattice")
@export var current_lattice_node: LatticeNode3D

# move_mesh_lattice

@export_group("Mesh Lattice")
@export var lattice_mesh: MeshInstance3D
var lattice_gen: MeshLattice3D
@export var current_lattice_vertex := -1 # invalid by default to ensure it gets set properly for each level
@export var debug_lattice := true

## turning

@export_category("Turning")

@export var turn_speed: float = 7.5 # per angle
var allow_skip_turn_anim := true
var beat_on_turn := true
var beat_on_turn_changes_bpm := false

var _turn_tween : Tween
var _is_turning := false
var _last_complete_turn_yaw
var _target_rotation


## node

func _ready() -> void:
	# dungeon.quarter_note.connect(_on_quarter_beat)
	
	# set default values
	pivot.basis = transform.basis
	center.basis = transform.basis
	basis = Basis.IDENTITY
	_target_rotation = pivot.rotation.y
	_last_complete_turn_yaw = _target_rotation
	
	# snap to lattice

	match _movement_system:
		MovementSystem.NodeLattice:
			if !current_lattice_node:
				push_error("Player error: NodeLattice movement in use but no initial node selected with current_lattice_node")
				Global.panic()
			elif _snap_to_lattice:
				_target_position = current_lattice_node.position
				_target_basis = current_lattice_node.basis
				position = _target_position
				basis = _target_basis
				_last_complete_move_position = _target_position
		MovementSystem.MeshLattice:
			if !lattice_mesh or !lattice_mesh.mesh:
				push_error("Player error: MeshLattice movement in use but lattice_mesh is invalid")
				Global.panic()
			else:
				lattice_gen = MeshLattice3D.new(lattice_mesh)
				
				if current_lattice_vertex < 0:
					push_error("Player error: MeshLattice movement in use but no initial vertex selected with current_lattice_vertex")
					Global.panic()
				elif _snap_to_lattice:
					_target_position = lattice_gen.vertices[current_lattice_vertex]
					# Note: set _target_basis here once MeshLattice normals get implemented
					position = _target_position
					basis = Basis.IDENTITY
					_last_complete_move_position = _target_position
		_:
			pass


func _process(delta: float) -> void:
	var _is_dodge_active = Input.is_action_pressed("dodge")
	
	# handle move input
	if Input.is_action_just_pressed("move_left"):
		var move_func := func(): move(Global.Direction2D.Left)
		var turn_func := func(): turn_left()
		
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
		var move_func := func(): move(Global.Direction2D.Right)
		var turn_func := func(): turn_right()
		
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
		move(Global.Direction2D.Up)
	elif Input.is_action_just_pressed("move_backward"):
		move(Global.Direction2D.Down)
	
	# handle turn input
	if Input.is_action_just_pressed("look_left"):
		turn_left()
	elif Input.is_action_just_pressed("look_right"):
		turn_right()
	
	# debug
	if _movement_system == MovementSystem.MeshLattice and lattice_gen and debug_lattice: lattice_gen.draw_debug_labels(delta)


## beat

#func _on_quarter_beat() -> void:
	#for callable in _move_queue: callable.call()
	#_move_queue.clear()
	#
	#for callable in _turn_queue: callable.call()
	#_turn_queue.clear()


## player

func _beat(change_bpm) -> void:
	if dungeon: dungeon.beat(change_bpm)


func _check_for_ground(relative_position: Vector3) -> bool:
	var wall_margin = 0.1
	
	%WallRayCast.target_position = relative_position + relative_position.normalized() * wall_margin
	%GroundRayCast.position = relative_position
	%GroundRayCast.target_position = -basis.y * (center.position.y + _max_step_height)
	
	%WallRayCast.force_raycast_update()
	%GroundRayCast.force_raycast_update()
	
	if %WallRayCast.is_colliding():
		# wall hit
		# print("hit wall")
		return false
	else:
		if %GroundRayCast.is_colliding() and %GroundRayCast.get_collision_normal().angle_to(basis.y) <= _max_floor_angle:
			# ground hit
			# print("hit ground")
			return true
		else:
			# no hit
			# print("hit nothing")
			return false


func axis_aligned_basis(basis: Basis, axis: Vector3) -> Basis:
	basis.x = -basis.z.cross(axis);
	basis.y = axis;
	basis = basis.orthonormalized();
	return basis;


# workaround to find the center of the face for a triangulated quad
func find_tri_midpoint(faces: PackedVector3Array, index: int) -> Vector3:
	var point_a = faces[index * 3]
	var point_b = faces[index * 3 + 1]
	var point_c = faces[index * 3 + 2]
	
	var angle_ab = point_a.angle_to(point_b)
	var angle_ac = point_a.angle_to(point_c)
	var angle_cb = point_c.angle_to(point_b)
	
	# the largest angle is opposite the hypotenuse. find the largest angle and then return the
	# midpoint of the two opposite points
	return (point_a + point_b) * 0.5 if angle_ab > angle_ac and angle_ab > angle_cb else (point_a + point_c) * 0.5 if angle_ac > angle_ab and angle_ac > angle_cb else (point_a + point_c) * 0.5


func move_world_grid(direction: Global.Direction2D) -> void:
	if _is_moving:
		if !allow_skip_move_anim: return
		
		var difference = position.distance_to(_target_position)
		
		# complete movement instantly
		_move_tween.kill()
		position = _target_position
		_last_complete_move_position = _target_position
		_is_moving = false
		
		if beat_on_move: _beat(beat_on_move_changes_bpm)
		
		# if the movement was nearly complete (based on this threshold) and skips are allowed,
		# start a new movement. otherwise, cancel.
		if difference > 0.2: return
	
	var tile_offset = Vector3(
		Global.direction2d_horizontal_to_bipolarf(direction),
		0.0,
		-Global.direction2d_vertical_to_bipolarf(direction)
	) * world_grid_scale
	var tile_position = (center.basis.x * tile_offset.x) + (center.basis.z * tile_offset.z)
	
	if !_check_for_ground(tile_offset):
		if beat_on_move and beat_on_collide: _beat(beat_on_move_changes_bpm)
		return
	
	_is_moving = true
	
	var original_position = position
	_target_position = _last_complete_move_position + tile_position
	
	if _move_tween: _move_tween.kill()
	_move_tween = create_tween()
	_move_tween.set_ease(Tween.EASE_OUT).tween_method(func(alpha):
		position = lerp(original_position, _target_position, alpha),
		0.0, 1.0, original_position.distance_to(_target_position) / move_speed)
	
	await _move_tween.finished
	
	if beat_on_move: _beat(beat_on_move_changes_bpm)
	
	# complete move
	_last_complete_move_position = _target_position
	_is_moving = false


func move_node_lattice(direction: Global.Direction2D) -> void:
	if _is_moving:
		if !allow_skip_move_anim: return
		
		var difference = position.distance_to(_target_position)
		
		# complete movement instantly
		_move_tween.kill()
		position = _target_position
		basis = _target_basis
		_last_complete_move_position = _target_position
		_is_moving = false
		
		if beat_on_move: _beat(beat_on_move_changes_bpm)
		
		# if the movement was nearly complete (based on this threshold) and skips are allowed,
		# start a new movement. otherwise, cancel.
		if difference > 0.2: return
	
	var next_lattice_node = current_lattice_node.get_neighbor(Global.direction2d_turn(direction, facing_direction))
	
	if next_lattice_node == null:
		if beat_on_move and beat_on_collide: _beat(beat_on_move_changes_bpm)
		return
	
	_is_moving = true
	
	var original_position = position
	_target_position = next_lattice_node.position
	_target_basis = next_lattice_node.basis
	
	current_lattice_node = next_lattice_node
	
	if _move_tween: _move_tween.kill()
	_move_tween = create_tween()
	_move_tween.set_ease(Tween.EASE_OUT).tween_method(func(alpha):
		position = lerp(original_position, _target_position, alpha)
		basis = basis.slerp(_target_basis, alpha),
		0.0, 1.0, original_position.distance_to(_target_position) / move_speed)
	
	await _move_tween.finished
	
	if beat_on_move: _beat(beat_on_move_changes_bpm)
	
	# complete move
	_last_complete_move_position = _target_position
	_is_moving = false


func move_mesh_lattice(direction: Global.Direction2D) -> void:
	if _is_moving:
		if !allow_skip_move_anim: return
		
		var difference = position.distance_to(_target_position)
		
		# complete movement instantly
		_move_tween.kill()
		position = _target_position
		basis = _target_basis
		_last_complete_move_position = _target_position
		_is_moving = false
		
		if beat_on_move: _beat(beat_on_move_changes_bpm)
		
		# if the movement was nearly complete (based on this threshold) and skips are allowed,
		# start a new movement. otherwise, cancel.
		if difference > 0.2: return
	
	var direction_vector = Vector3(
		Global.direction2d_horizontal_to_bipolarf(direction),
		0.0,
		Global.direction2d_vertical_to_bipolarf(direction)
	)
	direction_vector = (center.basis.x * direction_vector.x) + (-center.basis.z * direction_vector.z)
	var next_lattice_index = lattice_gen.traverse(current_lattice_vertex, direction_vector)
	
	if next_lattice_index < 0:
		if beat_on_move and beat_on_collide: _beat(beat_on_move_changes_bpm)
		return
	
	_is_moving = true
	
	var original_position = position
	_target_position = lattice_gen.vertices[next_lattice_index]
	_target_basis = Basis.IDENTITY # Note: construct from normals
	
	current_lattice_vertex = next_lattice_index
	
	if _move_tween: _move_tween.kill()
	_move_tween = create_tween()
	_move_tween.set_ease(Tween.EASE_OUT).tween_method(func(alpha):
		position = lerp(original_position, _target_position, alpha)
		basis = basis.slerp(_target_basis, alpha),
		0.0, 1.0, original_position.distance_to(_target_position) / move_speed)
	
	await _move_tween.finished
	
	if beat_on_move: _beat(beat_on_move_changes_bpm)
	
	# complete move
	_last_complete_move_position = _target_position
	_is_moving = false


func move(direction: Global.Direction2D) -> void:
	match _movement_system:
		MovementSystem.WorldGrid:
			move_world_grid(direction)
		MovementSystem.NodeLattice:
			move_node_lattice(direction)
		MovementSystem.MeshLattice:
			move_mesh_lattice(direction)


# Negative == Left, Positive == Right
func turn(direction: Global.Direction1D) -> void:
	if _is_turning: return
	
	if _is_turning:
		if !allow_skip_turn_anim: return
		
		var difference = abs(angle_difference(pivot.rotation.y, _target_rotation))
		
		# complete rotation instantly
		_turn_tween.kill()
		pivot.rotation.y = _target_rotation
		_last_complete_turn_yaw = _target_rotation
		facing_direction = _target_facing_direction
		center.basis = pivot.basis
		_is_turning = false
		
		if beat_on_turn: _beat(beat_on_turn_changes_bpm)
		
		# if the rotation was nearly complete (based on this threshold) and skips are allowed,
		# start a new rotation. otherwise, cancel.
		if difference > deg_to_rad(20.0): return
	
	_is_turning = true
	
	var _original_rotation = pivot.rotation
	_target_rotation = _last_complete_turn_yaw - deg_to_rad(Global.bool_to_bipolarf(Global.direction1d_to_bool(direction)) * 90.0)
	_target_facing_direction = Global.direction2d_turn(facing_direction, Global.bool_to_bipolar(Global.direction1d_to_bool(direction)))
	
	if _turn_tween: _turn_tween.kill()
	_turn_tween = create_tween()
	_turn_tween.set_ease(Tween.EASE_OUT).tween_method(func(alpha):
		pivot.rotation.y = lerp_angle(_original_rotation.y, _target_rotation, alpha),
		0.0, 1.0, abs(angle_difference(_original_rotation.y, _target_rotation)) / turn_speed)
	
	if beat_on_turn: _beat(beat_on_turn_changes_bpm)
	
	await _turn_tween.finished
	
	# complete turn
	_last_complete_turn_yaw = _target_rotation
	facing_direction = _target_facing_direction
	center.basis = pivot.basis
	_is_turning = false


func turn_left() -> void: turn(Global.Direction1D.Negative)


func turn_right() -> void: turn(Global.Direction1D.Positive)

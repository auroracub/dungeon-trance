
@tool class_name LatticeNode3D extends Marker3D

@export var default_spacing: float = 1.0

@export_group("Left Node")
@export var left_neighbor: LatticeNode3D = null
@export_tool_button("Extrude Left") var extrude_left = func(): extrude(GlobalStatic.Direction2D.Left, default_spacing)
@export_tool_button("Focus Left") var focus_left = func(): EditorInterface.call_deferred("edit_node", left_neighbor)

@export_group("Front Node")
@export var front_neighbor: LatticeNode3D = null
@export_tool_button("Extrude Front") var extrude_front = func(): extrude(GlobalStatic.Direction2D.Up, default_spacing)
@export_tool_button("Focus Front") var focus_front = func(): EditorInterface.call_deferred("edit_node", front_neighbor)

@export_group("Right Node")
@export var right_neighbor: LatticeNode3D = null
@export_tool_button("Extrude Right") var extrude_right = func(): extrude(GlobalStatic.Direction2D.Right, default_spacing)
@export_tool_button("Focus Right") var focus_right = func(): EditorInterface.call_deferred("edit_node", right_neighbor)

@export_group("Back Node")
@export var back_neighbor: LatticeNode3D = null
@export_tool_button("Extrude Back") var extrude_back = func(): extrude(GlobalStatic.Direction2D.Down, default_spacing)
@export_tool_button("Focus Back") var focus_back = func(): EditorInterface.call_deferred("edit_node", back_neighbor)

@export_category("Debug")
@export var draw_debug_text := true
@export var draw_debug_arrows := true
@export var hide_while_playing := true


func _exit_tree() -> void:
	remove_from_neighbors()
	reset()


func get_neighbor(direction: GlobalStatic.Direction2D) -> LatticeNode3D:
	match direction:
		GlobalStatic.Direction2D.Left:
			return left_neighbor
		GlobalStatic.Direction2D.Up:
			return front_neighbor
		GlobalStatic.Direction2D.Right:
			return right_neighbor
		GlobalStatic.Direction2D.Down:
			return back_neighbor
		_:
			return null


func set_neighbor(direction: GlobalStatic.Direction2D, node: LatticeNode3D, force: bool = true) -> bool:
	match direction:
		GlobalStatic.Direction2D.Left:
			if !force and left_neighbor: return false
			left_neighbor = node
		GlobalStatic.Direction2D.Up:
			if !force and front_neighbor: return false
			front_neighbor = node
		GlobalStatic.Direction2D.Right:
			if !force and right_neighbor: return false
			right_neighbor = node
		GlobalStatic.Direction2D.Down:
			if !force and back_neighbor: return false
			back_neighbor = node
		_:
			return false
			
	return true


func remove_neighbor(direction: GlobalStatic.Direction2D) -> void:
	set_neighbor(direction, null, true)


func get_neighbors_dict() -> Dictionary[GlobalStatic.Direction2D, LatticeNode3D]:
	return {
		GlobalStatic.Direction2D.Left: left_neighbor,
		GlobalStatic.Direction2D.Up: front_neighbor,
		GlobalStatic.Direction2D.Right: right_neighbor,
		GlobalStatic.Direction2D.Down: back_neighbor
	}


func get_neighbors_list() -> Array[LatticeNode3D]:
	return [
		left_neighbor,
		front_neighbor,
		right_neighbor,
		back_neighbor
	]


func _get_neighbors_debug() -> void:
	var n = get_neighbors_dict()
	for k in n: print(GlobalStatic.direction2d_to_string(k), ": ", n[k])


func _process(delta: float) -> void:
	if hide_while_playing and !Engine.is_editor_hint(): return
	
	if draw_debug_text: DebugDraw3D.draw_text(global_position + basis.y * 0.4, name, 16, Color.WHITE, delta)
	if draw_debug_arrows:
		if left_neighbor: DebugDraw3D.draw_arrow(global_position, left_neighbor.global_position, Color.RED, 0.1, true, delta)
		if front_neighbor: DebugDraw3D.draw_arrow(global_position, front_neighbor.global_position, Color.BLUE, 0.1, true, delta)
		if right_neighbor: DebugDraw3D.draw_arrow(global_position, right_neighbor.global_position, Color.RED, 0.1, true, delta)
		if back_neighbor: DebugDraw3D.draw_arrow(global_position, back_neighbor.global_position, Color.BLUE, 0.1, true, delta)


func remove_from_neighbors() -> void:
	for i in get_neighbors_list():
		if !i: continue
		var n = i.get_neighbors_dict()
		for j in n.keys():
			if n[j] and n[j] == self: i.remove_neighbor(j)


func reset() -> void:
	left_neighbor = null
	front_neighbor = null
	right_neighbor = null
	back_neighbor = null


func extrude(direction: GlobalStatic.Direction2D, distance: float = 1.0) -> bool:
	var n = get_neighbor(direction)
	if n: return false
	
	var sibling = LatticeNode3D.new()
	sibling.set_neighbor(GlobalStatic.direction2d_invert(direction), self)
	if is_instance_valid(sibling):
		add_sibling(sibling)
		sibling.owner = owner # get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().root
		sibling.name = name
		set_neighbor(direction, sibling)
		var offset = GlobalStatic.direction2d_to_vector2i(direction) * distance
		sibling.global_position = Vector3(offset.x, 0.0, offset.y)
	else:
		push_warning("Warning: unable to create sibling, is_instance_valid returned false")
	
	return true


@tool class_name LatticeNode3D extends Marker3D

@export_group("Left Node")
@export var left_neighbor: LatticeNode3D = null
@export_tool_button("Extrude Left") var extrude_left = func(): extrude(Global.Direction2D.Left)
@export_tool_button("Focus Left") var focus_left = func(): EditorInterface.call_deferred("edit_node", left_neighbor)

@export_group("Front Node")
@export var front_neighbor: LatticeNode3D = null
@export_tool_button("Extrude Front") var extrude_front = func(): extrude(Global.Direction2D.Up)
@export_tool_button("Focus Front") var focus_front = func(): EditorInterface.call_deferred("edit_node", front_neighbor)

@export_group("Right Node")
@export var right_neighbor: LatticeNode3D = null
@export_tool_button("Extrude Right") var extrude_right = func(): extrude(Global.Direction2D.Right)
@export_tool_button("Focus Right") var focus_right = func(): EditorInterface.call_deferred("edit_node", right_neighbor)

@export_group("Back Node")
@export var back_neighbor: LatticeNode3D = null
@export_tool_button("Extrude Back") var extrude_back = func(): extrude(Global.Direction2D.Down)
@export_tool_button("Focus Back") var focus_back = func(): EditorInterface.call_deferred("edit_node", back_neighbor)

@export_category("Debug")
@export var draw_debug_text := true
@export var draw_debug_arrows := true
@export var hide_while_playing := true


func get_neighbor(direction: Global.Direction2D) -> LatticeNode3D:
	match direction:
		Global.Direction2D.Left:
			return left_neighbor
		Global.Direction2D.Up:
			return front_neighbor
		Global.Direction2D.Right:
			return right_neighbor
		Global.Direction2D.Down:
			return back_neighbor
		_:
			return null


func set_neighbor(direction: Global.Direction2D, node: LatticeNode3D, force: bool = true) -> bool:
	match direction:
		Global.Direction2D.Left:
			if force and left_neighbor: return false
			left_neighbor = node
		Global.Direction2D.Up:
			if force and front_neighbor: return false
			front_neighbor = node
		Global.Direction2D.Right:
			if force and right_neighbor: return false
			right_neighbor = node
		Global.Direction2D.Down:
			if force and back_neighbor: return false
			back_neighbor = node
		_:
			return false
			
	return true


func remove_neighbor(direction: Global.Direction2D) -> void:
	set_neighbor(direction, null, true)


func get_neighbors_dict() -> Dictionary[Global.Direction2D, LatticeNode3D]:
	return {
		Global.Direction2D.Left: left_neighbor,
		Global.Direction2D.Up: front_neighbor,
		Global.Direction2D.Right: right_neighbor,
		Global.Direction2D.Down: back_neighbor
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
	for k in n: print(Global.direction2d_to_string(k), ": ", n[k])


func _process(delta: float) -> void:
	if hide_while_playing and !Engine.is_editor_hint(): return
	
	if draw_debug_text: DebugDraw3D.draw_text(global_position + basis.y * 0.4, name, 16, Color.WHITE, delta)
	if draw_debug_arrows:
		if left_neighbor: DebugDraw3D.draw_arrow(global_position, left_neighbor.global_position, Color.RED, 0.1, true, delta)
		if front_neighbor: DebugDraw3D.draw_arrow(global_position, front_neighbor.global_position, Color.BLUE, 0.1, true, delta)
		if right_neighbor: DebugDraw3D.draw_arrow(global_position, right_neighbor.global_position, Color.RED, 0.1, true, delta)
		if back_neighbor: DebugDraw3D.draw_arrow(global_position, back_neighbor.global_position, Color.BLUE, 0.1, true, delta)


func delete() -> void:
	for i in get_neighbors_list():
		var n = i.get_neighbors_dict()
		for j in n.keys(): if n[j] == self: i.remove_neighbor(j)
	queue_free()


func reset() -> void:
	left_neighbor = null
	front_neighbor = null
	right_neighbor = null
	back_neighbor = null


func extrude(direction: Global.Direction2D, distance: float = 1.0) -> bool:
	var n = get_neighbor(direction)
	if n: return false
	
	var sibling = LatticeNode3D.new()
	sibling.set_neighbor(Global.direction2d_invert(direction), self)
	add_sibling(sibling)
	sibling.global_position
	
	return true

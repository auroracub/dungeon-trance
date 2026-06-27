
@tool class_name LatticeNode3D extends Marker3D

@export var left_neighbor: LatticeNode3D = null
@export var front_neighbor: LatticeNode3D = null
@export var right_neighbor: LatticeNode3D = null
@export var back_neighbor: LatticeNode3D = null
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


func get_neighbors() -> Dictionary[Global.Direction2D, LatticeNode3D]:
	return {
		Global.Direction2D.Left: left_neighbor,
		Global.Direction2D.Up: front_neighbor,
		Global.Direction2D.Right: right_neighbor,
		Global.Direction2D.Down: back_neighbor
	}


func _get_neighbors_debug() -> void:
	var n = get_neighbors()
	for k in n: print(Global.direction2d_to_string(k), ": ", n[k])


func _process(delta: float) -> void:
	if hide_while_playing and !Engine.is_editor_hint(): return
	
	if draw_debug_text: DebugDraw3D.draw_text(global_position + basis.y * 0.4, name, 16, Color.WHITE, delta)
	if draw_debug_arrows:
		if left_neighbor: DebugDraw3D.draw_arrow(global_position, left_neighbor.global_position, Color.RED, 0.1, true, delta)
		if front_neighbor: DebugDraw3D.draw_arrow(global_position, front_neighbor.global_position, Color.BLUE, 0.1, true, delta)
		if right_neighbor: DebugDraw3D.draw_arrow(global_position, right_neighbor.global_position, Color.RED, 0.1, true, delta)
		if back_neighbor: DebugDraw3D.draw_arrow(global_position, back_neighbor.global_position, Color.BLUE, 0.1, true, delta)


class_name LatticeNode extends Marker3D

@export var left_neighbor: LatticeNode = null
@export var front_neighbor: LatticeNode = null
@export var right_neighbor: LatticeNode = null
@export var back_neighbor: LatticeNode = null

func get_neighbor(direction: Global.Direction2D) -> LatticeNode:
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


func get_neighbors() -> Dictionary[Global.Direction2D, LatticeNode]:
	return {
		Global.Direction2D.Left: left_neighbor,
		Global.Direction2D.Up: front_neighbor,
		Global.Direction2D.Right: right_neighbor,
		Global.Direction2D.Down: back_neighbor
	}


func _get_neighbors_debug() -> void:
	var n = get_neighbors()
	for k in n: print(Global.direction2d_to_string(k), ": ", n[k])


@tool class_name MeshLattice3D extends RefCounted

var mesh_instance: MeshInstance3D
var index_graph: Dictionary = {} # { vertex indices: array of neighbor indices }
var vertices: PackedVector3Array
# var normals: PackedVector3Array

@export var draw_debug_text := false
@export var hide_while_playing := true

func _init(p_mesh_instance: MeshInstance3D) -> void:
	if p_mesh_instance and p_mesh_instance.mesh:
		mesh_instance = p_mesh_instance
		_build_graph_from_line_mesh(p_mesh_instance.mesh)

# requires a 3d wireframe mesh with edges. faces are irrelevant.
# if you use modeling software to build the mesh, make sure to export with 'loose edges' enabled.
func _build_graph_from_line_mesh(mesh: Mesh) -> void:
	var arrays: Array = mesh.surface_get_arrays(0)
	if arrays.is_empty(): return
	
	vertices = arrays[Mesh.ARRAY_VERTEX]
	# normals = arrays[Mesh.ARRAY_NORMAL] # idk
	
	var vertex_array: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var index_array: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	
	# pre-size dictionary
	for i in range(vertex_array.size()):
		index_graph[i] = []
		
	# step by 2 through the index array to get edge vertex pairs
	# since it is PRIMITIVE_LINES, indices [0,1] is line 1, [2,3] is line 2...
	for i in range(0, index_array.size(), 2):
		if i + 1 >= index_array.size():
			break # safeguard for odd vertex count
		
		var v_a: int = index_array[i]
		var v_b: int = index_array[i + 1]
		
		# connect the line vertices bidirectionally
		_add_undirected_edge(v_a, v_b)


func _add_undirected_edge(v_a: int, v_b: int) -> void:
	if not index_graph[v_a].has(v_b):
		index_graph[v_a].append(v_b)
	if not index_graph[v_b].has(v_a):
		index_graph[v_b].append(v_a)


func get_vertex_neighbors(p_index: int) -> Array:
	if index_graph.has(p_index):
		return index_graph[p_index]
	return []


func get_closest_vertex(p_position: Vector3) -> int:
	var sorted_indices = range(vertices.size())
	sorted_indices.sort_custom(func(a: int, b: int): 
		return vertices[a].distance_squared_to(p_position) < vertices[b].distance_squared_to(p_position)
	)
	return sorted_indices[0]


## less flexible but more optimized when you are sure the position is within a certain distance of the
## vertex and all vertices are spaced greater than this threshold
#func get_vertex_by_distance_threshold(p_position: Vector3, p_threshold: float = 0.1) -> int:
	#for i in range(vertices.size()):
		#if p_position.distance_to(vertices[i]) <= p_threshold: return i
	#return -1


func get_vertex_position(p_index: int) -> Vector3:
	return vertices[p_index] * mesh_instance.global_transform


func traverse(p_index: int, p_direction: Vector3, p_max_angle: float = 45.0) -> int:
	var center = vertices[p_index]
	var neighbors = get_vertex_neighbors(p_index)
	
	if neighbors.is_empty(): return -1
	
	var a_max: float = abs(deg_to_rad(p_max_angle))
	var a_min := INF
	var n_min := -1
	
	for n in neighbors:
		var a = abs(center.direction_to(vertices[n]).angle_to(p_direction))
		
		if a < a_max and a < a_min:
			a_min = a
			n_min = n
	
	return n_min


func draw_debug_labels(duration: float) -> void:
	if hide_while_playing and !Engine.is_editor_hint(): return
	
	if draw_debug_text:
		for i in range(vertices.size()):
			DebugDraw3D.draw_text(vertices[i] + mesh_instance.global_position + mesh_instance.global_basis.y * 0.4, str(i), 16, Color.WHITE, duration)

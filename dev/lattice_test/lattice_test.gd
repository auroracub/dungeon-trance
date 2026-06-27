
extends Node3D

@onready var mesh := %Mesh
@onready var marker := %Marker

var lattice: MeshLattice3D


func _ready() -> void:
	lattice = MeshLattice3D.new(mesh)
	
	for i in range(lattice.vertices.size()):
		var label1 = Label3D.new()
		label1.text = str(i)
		label1.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		add_child(label1)
		label1.global_position = lattice.vertices[i] + mesh.global_position + Vector3(0.0, -0.1, 0.0)
		
		var label2 = Label3D.new()
		label2.text = str(lattice.vertices[i])
		label2.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		add_child(label2)
		label2.global_position = lattice.vertices[i] + mesh.global_position + Vector3(0.0, -0.5, 0.0)


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed_by_event("interact", event):
		print("TEST")
		var center_id = lattice.get_closest_vertex(marker.global_position)
		print("center id: ", center_id)
		var center = lattice.get_vertex_position(center_id)
		print("center: ", center)
		var neighbors = lattice.get_vertex_neighbors(center_id)
		print("neighbors: ", neighbors)
		var forward = -marker.basis.z
		print("forward: ", forward)
		var front = lattice.traverse(center_id, forward)
		print("front id: ", front)
		if front >= 0:
			print("front: ", lattice.get_vertex_position(front))
			print("angle: ", center.direction_to(lattice.vertices[front]).angle_to(forward))
			DebugDraw3D.draw_arrow(center, lattice.vertices[front], Color.LIGHT_BLUE, 0.1, true, 1.0)
		DebugDraw3D.draw_arrow(center, forward + center, Color.DEEP_PINK, 0.1, true, 1.0)
		print("----------")


extends Node3D

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed_by_event("interact", event):
		print(%RayCast3D)
		var target = %RayCast3D.get_collider() # A CollisionObject3D.
		var shape_id = %RayCast3D.get_collider_shape() # The shape index in the collider.
		var owner_id = target.shape_find_owner(shape_id) # The owner ID in the collider.
		var shape = target.shape_owner_get_owner(owner_id)
		
		print("collider: ", %RayCast3D.get_collider())
		print("collider transform: ", target.shape_owner_get_transform(owner_id))
		print("face index: ", %RayCast3D.get_collision_face_index())
		var id = %RayCast3D.get_collision_face_index() * 3
		var avg = (shape.shape.get_faces()[id] + shape.shape.get_faces()[id + 1] + shape.shape.get_faces()[id + 2]) / 3
		print("face position: ", avg)

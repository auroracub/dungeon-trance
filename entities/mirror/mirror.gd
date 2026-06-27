
# credit: https://github.com/Norodix/GodotMirror
@tool class_name Mirror extends Node3D

@export var size: Vector2 = Vector2(1.28, 2.54):
	set(value):
		size = value
		%Quad.mesh.size = size
		%Quad.position = Vector3(0.0, size.y * 0.5, 0.0)
		%SubViewport.size = size * pixels_per_unit
@export var pixels_per_unit: int = 64
@export var cull_near: float = 0.05
@export var cull_far: float = 50.0
@export_flags_3d_render var cull_mask: int = 0xFFFFF
@export var max_update_distance: float = 50.0

var main_cam: Camera3D
var last_main_cam_pos: Vector3


func _ready() -> void:
	# set camera
	if Engine.is_editor_hint():
		main_cam = Engine.get_singleton(&"EditorInterface").get_editor_viewport_3d().get_camera_3d()
	else:
		main_cam = get_viewport().get_camera_3d()
	
	last_main_cam_pos = main_cam.global_position
	setup()
	update_camera() # force update


func setup():
	var viewport_texture = %SubViewport.get_texture()
	%Camera3D.cull_mask = cull_mask
	%Camera3D.fov = main_cam.fov
	%Quad.mesh.size = size
	%Quad.position = Vector3(0.0, size.y * 0.5, 0.0)
	%SubViewport.size = size * pixels_per_unit
	%Quad.get_active_material(0).set_shader_parameter(&"viewport_texture", viewport_texture)


func _process(delta: float) -> void:
	if !is_visible_in_tree(): return
	if !is_instance_valid(main_cam): return
	if is_zero_approx(last_main_cam_pos.distance_squared_to(main_cam.global_position)): return
	
	# %Camera3D.fov = main_cam.fov # in case of dynamic fov
	last_main_cam_pos = main_cam.global_position
	var difference = %Quad.global_position - last_main_cam_pos
	if difference.length() > max_update_distance:
		%SubViewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	else:
		%SubViewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	
	update_camera()


func update_camera():
	# transform mirror camera to opposite side of mirror plane
	var mirror_normal = %Quad.global_basis.z
	var mirror_transform = get_mirror_transform(mirror_normal, %Quad.global_position)
	%Camera3D.global_transform = mirror_transform * main_cam.global_transform
	
	# look perpendicular into mirror plane for frustum camera
	%Camera3D.global_transform = %Camera3D.global_transform.looking_at(
		(%Camera3D.global_position + last_main_cam_pos) * 0.5, %Quad.global_basis.y)
	var camera_to_mirror_offset = %Quad.global_position - %Camera3D.global_position
	
	# transform offset to camera's local coordinate system (frustum offset uses local space)
	var near = abs(camera_to_mirror_offset.dot(mirror_normal)) + cull_near
	var far = camera_to_mirror_offset.length() + cull_far
	var camera_to_mirror_offset_local = %Camera3D.global_basis.inverse() * camera_to_mirror_offset
	var frustum_offset = Vector2(camera_to_mirror_offset_local.x, camera_to_mirror_offset_local.y)
	%Camera3D.set_frustum(size.y, frustum_offset, near, far)


static func get_mirror_transform(normal: Vector3, offset: Vector3) -> Transform3D:
	var basis_x = Vector3.RIGHT	- (2.0 * Vector3(normal.x * normal.x, normal.x * normal.y, normal.x * normal.z))
	var basis_y = Vector3.UP	- (2.0 * Vector3(normal.y * normal.x, normal.y * normal.y, normal.y * normal.z))
	var basis_z = Vector3.BACK 	- (2.0 * Vector3(normal.z * normal.x, normal.z * normal.y, normal.z * normal.z))
	var origin = 2.0 * normal.dot(offset) * normal
	return Transform3D(basis_x, basis_y, basis_z, origin)

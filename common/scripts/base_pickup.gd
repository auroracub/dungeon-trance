
class_name BasePickup extends BaseInteractable


func destroy() -> void:
	queue_free()


func interact() -> void:
	super()
	destroy()

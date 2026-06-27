
class_name Candy extends BasePickup


#func _ready() -> void:
	#%Area3D.body_entered.connect(_on_overlap)
#
#
#func _on_overlap(body: Node3D) -> void:
	#print(body)
	#var player = Global.get_player()
	#if player and body == player:
		#player.pick_up(self)

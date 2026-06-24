
class_name PhaseComponent extends Node

@export var energy_phases: Array[Global.EnergyState]

var object: Node3D
var dungeon: Dungeon
var _default_init: bool

func _init(_object: Node3D = null, _dungeon: Dungeon = null) -> void:
	_default_init = !_object or !_dungeon
	
	if !_default_init:
		object = _object
		dungeon = _dungeon

func _ready() -> void:
	if _default_init:
		object = owner as Node3D
		dungeon = object.owner as Dungeon
	
	if dungeon: dungeon.energy_state_changed.connect(_on_energy_state_changed)

func _on_energy_state_changed(old_state: Global.EnergyState, new_state: Global.EnergyState) -> void:
	var old_state_active = energy_phases.has(old_state)
	var new_state_active = energy_phases.has(new_state)
	
	if old_state_active and !new_state_active:
		object.visible = false
	elif !old_state_active and new_state_active:
		object.visible = true

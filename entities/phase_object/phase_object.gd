
class_name PhaseObject extends Node3D

@export var energy_phases: Array[Global.EnergyState]

@onready var phase_component: PhaseComponent # := PhaseComponent.new()

func _ready() -> void:
	phase_component = PhaseComponent.new(self, owner as Dungeon)
	phase_component.energy_phases = energy_phases
	add_child(phase_component)

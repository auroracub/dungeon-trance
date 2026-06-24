
class_name Dungeon extends Node3D

## tiles

@export var tile_size := 1.0

## bpm

@export var bpm_blend = 0.0

var _min_bpm := 10.0
var _max_bpm := 400.0
@onready var bpm := _min_bpm
var _beat_adjust_timer := 0.0
var _beat_play_timer := 0.0
var _beat_count := 1 # counted from 1

signal whole_note
signal half_note
signal quarter_note
signal eighth_note
#signal sixteenth_note

## audio players

@onready var _step_player : AudioStreamPlayer = %StepPlayer
@onready var _whole_note_player : AudioStreamPlayer = %WholeNotePlayer
@onready var _half_note_player : AudioStreamPlayer = %HalfNotePlayer
@onready var _quarter_note_player : AudioStreamPlayer = %QuarterNotePlayer
@onready var _eighth_note_player : AudioStreamPlayer = %EighthNotePlayer
#@onready var _sixteenth_note_player : AudioStreamPlayer = %SixteenthNotePlayer
@onready var _sequence_player : AudioStreamPlayer = %SequencePlayer
@onready var _background_player : AudioStreamPlayer = %BackgroundPlayer


## energy

var energy_state = Global.EnergyState.Subsonic
var subsonic_threshold := 45.0
var low_threshold := 90.0
var high_threshold := 180.0
var supersonic_threshold := 360.0

signal energy_state_changed(old_state: Global.EnergyState, new_state: Global.EnergyState)

@onready var energy_center = calculate_energy_center(energy_state)

## node

func _ready() -> void:
	if _whole_note_player and _whole_note_player.stream: _whole_note_player.play()
	
	RenderingServer.global_shader_parameter_set("bpm", bpm)
	RenderingServer.global_shader_parameter_set("bpm_alpha", remap(bpm, _min_bpm, _max_bpm, 0.0, 1.0))
	RenderingServer.global_shader_parameter_set("energy_level", float(energy_state))
	RenderingServer.global_shader_parameter_set("energy_alpha", float(energy_state) / float(Global.EnergyState.keys().size()))


func _process(delta: float) -> void:
	_update_debug_ui()
	_update_energy_state()
	
	_beat_adjust_timer += delta
	_beat_play_timer += delta
	
	var play_beat = false
	var note_value = 16.0
	
	if _beat_play_timer > (60.0) / (bpm * note_value):
		_beat_play_timer = 0.0
		_beat_count += 1
		play_beat = true
	
	if play_beat:
		var beat_value = int(note_value)
		var measure_count = 4
		var beat_number = _beat_count % beat_value
		
		# whole note
		if _beat_count % (beat_value / 1) == 0.0:
			whole_note.emit()
			if _whole_note_player and _whole_note_player.stream: _whole_note_player.play()
		
		# half note
		if _beat_count % (beat_value / 2) == 0.0:
			half_note.emit()
			if _half_note_player and _half_note_player.stream: _half_note_player.play()
		
		# quarter note
		if _beat_count % (beat_value / 4) == 0.0:
			quarter_note.emit()
			if _quarter_note_player and _quarter_note_player.stream: _quarter_note_player.play()
		
		# eigth note
		if _beat_count % (beat_value / 8) == 0.0:
			eighth_note.emit()
			if _eighth_note_player and _eighth_note_player.stream: _eighth_note_player.play()
		
		## sixteenth note
		#if _beat_count % (beat_value / 16) == 0.0:
			#sixteenth_note.emit()
			#if _sixteenth_note_player and _sixteenth_note_player.stream: _sixteenth_note_player.play()
		
		# custom pattern
		# if beat_number == 12:
			# if _step_player and _step_player.stream: _step_player.play()
		
		# custom pattern
		if beat_number == 8 or beat_number == 13:
			if _sequence_player and _sequence_player.stream: _sequence_player.play()
		
		# reset beat count
		if _beat_count >= beat_value * measure_count: _beat_count = 1


## game

func beat(change_bpm: bool = true) -> void:
	if change_bpm:
		var new_bpm = clampf(60.0 / maxf(0.01, _beat_adjust_timer), _min_bpm, _max_bpm)
		energy_center = calculate_energy_center(energy_state)
		bpm = lerpf(
			new_bpm,
			energy_center,
			clampf(1.0 / pow(abs(energy_center - new_bpm), 2.0), 0.0, 0.9)
		)
		_beat_adjust_timer = 0.0
	_step_player.play()
	RenderingServer.global_shader_parameter_set("bpm", bpm)
	RenderingServer.global_shader_parameter_set("bpm_alpha", remap(bpm, subsonic_threshold, supersonic_threshold, 0.0, 1.0))


## energy

func _update_energy_state() -> void:
	set_energy_state(
		Global.EnergyState.Subsonic if bpm < subsonic_threshold else
		Global.EnergyState.Low if bpm < low_threshold else
		Global.EnergyState.Medium if bpm < high_threshold else
		Global.EnergyState.High if bpm < supersonic_threshold else
		Global.EnergyState.Supersonic
	)

func set_energy_state(new_state: Global.EnergyState) -> void:
	if new_state != energy_state:
		energy_state_changed.emit(energy_state, new_state)
		energy_state = new_state
		
		RenderingServer.global_shader_parameter_set("energy_level", float(energy_state))
		RenderingServer.global_shader_parameter_set("energy_alpha", float(energy_state) / float(Global.EnergyState.keys().size()))

func calculate_energy_center(state) -> float:
	match state:
		Global.EnergyState.Subsonic:
			return (_min_bpm + subsonic_threshold) * 0.5
		Global.EnergyState.Low:
			return (subsonic_threshold + low_threshold) * 0.5
		Global.EnergyState.Medium:
			return (low_threshold + high_threshold) * 0.5
		Global.EnergyState.High:
			return (high_threshold + supersonic_threshold) * 0.5
		Global.EnergyState.Supersonic:
			return (supersonic_threshold + _max_bpm) * 0.5
		_:
			# default to subsonic
			return (_min_bpm + subsonic_threshold) * 0.5

## debug

func _update_debug_ui() -> void:
	%BPMValue.text = str(int(bpm))
	%EnergyValue.text = Global.EnergyState.keys()[energy_state]


class_name Dungeon extends Node3D

## tiles

@export var tile_size := 1.0

## bpm

@export var bpm_blend = 0.0

var bpm := 0.01
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


## node

func _ready() -> void:
	if _whole_note_player and _whole_note_player.stream: _whole_note_player.play()


func _process(delta: float) -> void:
	_beat_adjust_timer += delta
	_beat_play_timer += delta
	
	var play_beat = false
	var note_value = 16.0
	
	if _beat_play_timer > (60.0) / (bpm * note_value):
		_beat_play_timer = 0.0
		_beat_count += 1
		play_beat = true
	
	_update_bpm_debug()
	
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
		var new_bpm = 60.0 / maxf(0.01, _beat_adjust_timer)
		bpm = lerpf(bpm, new_bpm, 1.0 - clampf(bpm_blend, 0.0, 0.9))
		_beat_adjust_timer = 0.0
	_step_player.play()


## debug

func _update_bpm_debug() -> void:
	%BPMValue.text = str(int(bpm))

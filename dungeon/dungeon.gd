
class_name Dungeon extends Node3D

## bpm

var bpm := 0.01
var _beat_adjust_timer := 0.0
var _beat_play_timer := 0.0
var _beat_count := 1 # counted from 1


## audio players

@onready var _groove_player : AudioStreamPlayer = %GroovePlayer
@onready var _down_beat_player : AudioStreamPlayer = %DownBeatPlayer
@onready var _up_beat_player : AudioStreamPlayer = %UpBeatPlayer
@onready var _background_player : AudioStreamPlayer = %BackgroundPlayer


## node

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	_beat_adjust_timer += delta
	_beat_play_timer += delta
	
	var new_beat = false
	
	if _beat_play_timer > 15.0 / bpm:
		_beat_play_timer = 0.0
		_beat_count += 1
		new_beat = true
	
	if new_beat:
		# 8th note divisions over 2 measures
		
		if _beat_count == 1 or _beat_count == 8:
			_down_beat_player.play()
			
		if _beat_count == 6 or _beat_count == 14:
			_up_beat_player.play()
		
		if _beat_count >= 16:
			_beat_count = 1
			_down_beat_player.play()


## game

func beat() -> void:
	var new_bpm = 60.0 / maxf(0.01, _beat_adjust_timer)
	bpm = lerpf(bpm, new_bpm, 0.25)
	_beat_adjust_timer = 0.0
	_groove_player.play()

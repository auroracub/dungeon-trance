
extends MarginContainer

@export var dungeon: Dungeon
@export var player: Player

class DebugOption:
	var node: Node
	var getter: Callable
	var setter: Callable
	
	func _init(_node: Node, _getter: Callable, _setter: Callable) -> void:
		node = _node
		getter = _getter
		setter = _setter
	
	func setup() -> void:
		match node:
			var n when n is SpinBox:
				n.value = getter.call()
				n.value_changed.connect(setter)
			var n when n is CheckButton:
				n.button_pressed = getter.call()
				n.button_up.connect(func(): setter.call(node.button_pressed))
			var n when n is MenuButton:
				n.get_popup().index_pressed.connect(setter)
			_:
				if node:
					push_error("Error setting up debug overlay: unimplemented node type %s" % node)
				else:
					push_error("Error setting up debug overlay: invalid node")

func _ready() -> void:
	# setup options
	for option in [
		DebugOption.new(%MoveSpeed, func(): return player.move_speed, func(v): player.move_speed = v),
		DebugOption.new(%AllowSkipMoveAnim, func(): return player.allow_skip_move_anim, func(v): player.allow_skip_move_anim = v),
		DebugOption.new(%BeatOnCollide, func(): return player.beat_on_collide, func(v): player.beat_on_collide = v),
		DebugOption.new(%SideMoveBehavior, func(): return player.side_move_behavior, func(v): player.side_move_behavior = v),
		DebugOption.new(%TurnSpeed, func(): return player.turn_speed, func(v): player.turn_speed = v),
		DebugOption.new(%AllowSkipTurnAnim, func(): return player.allow_skip_turn_anim, func(v): player.allow_skip_turn_anim = v),
		DebugOption.new(%BeatOnTurn, func(): return player.beat_on_turn, func(v): player.beat_on_turn = v),
		DebugOption.new(%BeatOnTurnChangesBPM, func(): return player.beat_on_turn_changes_bpm, func(v): player.beat_on_turn_changes_bpm = v),
		DebugOption.new(%MinBPM, func(): return dungeon._min_bpm, func(v): dungeon._min_bpm = v),
		DebugOption.new(%MaxBPM, func(): return dungeon._max_bpm, func(v): dungeon._max_bpm = v),
		DebugOption.new(%SubsonicThreshold, func(): return dungeon.subsonic_threshold, func(v): dungeon.subsonic_threshold = v),
		DebugOption.new(%LowThreshold, func(): return dungeon.low_threshold, func(v): dungeon.low_threshold = v),
		DebugOption.new(%HighThreshold, func(): return dungeon.high_threshold, func(v): dungeon.high_threshold = v),
		DebugOption.new(%SupersonicThreshold, func(): return dungeon.supersonic_threshold, func(v): dungeon.supersonic_threshold = v)
	]:	option.setup()
	
	## setup options (manual method)
	#
	## setup spin boxes
	#
	#%MoveSpeed.value = player.move_speed
	#%MoveSpeed.value_changed.connect(func(value): player.move_speed = value)
	#
	#%TurnSpeed.value = player.turn_speed
	#%TurnSpeed.value_changed.connect(func(value): player.turn_speed = value)
	#
	#%MinBPM.value = dungeon._min_bpm
	#%MinBPM.value_changed.connect(func(value): dungeon._min_bpm = value)
	#
	#%MaxBPM.value = dungeon._max_bpm
	#%MaxBPM.value_changed.connect(func(value): dungeon._max_bpm = value)
	#
	#%SubsonicThreshold.value = dungeon.subsonic_threshold
	#%SubsonicThreshold.value_changed.connect(func(value): dungeon.subsonic_threshold = value)
	#
	#%LowThreshold.value = dungeon.low_threshold
	#%LowThreshold.value_changed.connect(func(value): dungeon.low_threshold = value)
	#
	#%HighThreshold.value = dungeon.high_threshold
	#%HighThreshold.value_changed.connect(func(value): dungeon.high_threshold = value)
	#
	#%SupersonicThreshold.value = dungeon.supersonic_threshold
	#%SupersonicThreshold.value_changed.connect(func(value): dungeon.supersonic_threshold = value)
	#
	## setup check buttons
	#
	#%AllowSkipMoveAnim.button_pressed = player.allow_skip_move_anim
	#%AllowSkipMoveAnim.button_up.connect(func(): player.allow_skip_move_anim = %AllowSkipMoveAnim.button_pressed)
	#
	#%BeatOnCollide.button_pressed = player.beat_on_collide
	#%BeatOnCollide.button_up.connect(func(): player.beat_on_collide = %BeatOnCollide.button_pressed)
	#
	#%AllowSkipTurnAnim.button_pressed = player.allow_skip_turn_anim
	#%AllowSkipTurnAnim.button_up.connect(func(): player.allow_skip_turn_anim = %AllowSkipTurnAnim.button_pressed)
	#
	#%BeatOnTurn.button_pressed = player.beat_on_turn
	#%BeatOnTurn.button_up.connect(func(): player.beat_on_turn = %BeatOnTurn.button_pressed)
	#
	#%BeatOnTurnChangesBPM.button_pressed = player.beat_on_turn_changes_bpm
	#%BeatOnTurnChangesBPM.button_up.connect(func(): player.beat_on_turn_changes_bpm = %BeatOnTurnChangesBPM.button_pressed)
	#
	## setup menu buttons
	#
	#%SideMoveBehavior.text = player.SideMoveBehavior.keys()[player.side_move_behavior]
	#%SideMoveBehavior.get_popup().index_pressed.connect(func(index):
		#player.side_move_behavior = index
		#%SideMoveBehavior.text = player.SideMoveBehavior.keys()[index]
	#)
	
	# show/hide game options
	
	%GameplayOptions.visible = %ShowGameplayOptions.button_pressed
	%ShowGameplayOptions.pressed.connect(func(): %GameplayOptions.visible = !%GameplayOptions.visible)
	
	# setup stats control
	
	%StatsButton.pressed.connect(func(): %StatsTabContainer.current_tab = (%StatsTabContainer.current_tab + 1) % %StatsTabContainer.get_tab_count())

func _process(delta: float) -> void:
	%EnergyValue.text = Global.EnergyState.keys()[dungeon.energy_state]
	%BPMValue.text = str(int(dungeon.bpm))

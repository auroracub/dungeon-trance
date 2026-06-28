
class_name GlobalStatic extends Node

## general

func panic() -> void:
	get_tree().quit()
	print("Thread ", OS.get_thread_caller_id(), " panicked due to game-breaking errors")


static func bool_to_unipolar(b: bool) -> int:
	return 1 if b else 0


static func bool_to_unipolarf(b: bool) -> float:
	return 1.0 if b else 0.0


static func bool_to_bipolar(b: bool) -> int:
	return 1 if b else -1


static func bool_to_bipolarf(b: bool) -> float:
	return 1.0 if b else -1.0


static func vector3_component(a: Vector3, b: Vector3) -> float:
	var l = b.length()
	return a.dot(b) / l if l > 0.0 else 0.0


static func _vector3_component_unsafe(a: Vector3, b: Vector3) -> float:
	return a.dot(b) / b.length()


static func vector3_component_squared(a: Vector3, b: Vector3) -> float:
	var l = b.length_squared()
	return a.dot(b) / l if l > 0.0 else 0.0


static func _vector3_component_squared_unsafe(a: Vector3, b: Vector3) -> float:
	return a.dot(b) / b.length_squared()


## player

var _player_ref: Player = null

func set_player(player: Player) -> void:
	_player_ref = player


func get_player() -> Player:
	return _player_ref


## energy

enum EnergyState { Subsonic, Low, Medium, High, Supersonic }


## direction 1d

enum Direction1D { Positive, Negative }


static func direction1d_invert(direction: Direction1D) -> Direction1D:
	match direction:
		GlobalStatic.Direction1D.Positive: return GlobalStatic.Direction1D.Negative
		GlobalStatic.Direction1D.Negative: return GlobalStatic.Direction1D.Positive
		_: return GlobalStatic.Direction1D.Negative


static func direction1d_to_bool(direction: Direction1D) -> bool:
	return direction == GlobalStatic.Direction1D.Positive


static func direction1d_to_bipolar(direction: GlobalStatic.Direction1D) -> int:
	return GlobalStatic.bool_to_bipolar(GlobalStatic.direction1d_to_bool(direction))


static func direction1d_to_bipolarf(direction: GlobalStatic.Direction1D) -> float:
	return GlobalStatic.bool_to_bipolarf(GlobalStatic.direction1d_to_bool(direction))


static func direction1d_to_unipolar(direction: GlobalStatic.Direction1D) -> int:
	return GlobalStatic.bool_to_unipolar(GlobalStatic.direction1d_to_bool(direction))


static func direction1d_to_unipolarf(direction: GlobalStatic.Direction1D) -> float:
	return GlobalStatic.bool_to_unipolarf(GlobalStatic.direction1d_to_bool(direction))


static func direction1d_to_string(direction: GlobalStatic.Direction1D) -> String:
	return GlobalStatic.Direction1D.keys()[direction]


static func direction1d_to_vertical2d(direction: GlobalStatic.Direction1D) -> Direction2D:
	return GlobalStatic.Direction2D.Up if GlobalStatic.direction1d_to_bool(direction) else GlobalStatic.Direction2D.Down


static func direction1d_to_horizontal2d(direction: Direction1D) -> Direction2D:
	return GlobalStatic.Direction2D.Left if GlobalStatic.direction1d_to_bool(direction) else GlobalStatic.Direction2D.Right


## direction 2d

enum Direction2D { Up, Right, Down, Left }


static func direction2d_invert(direction: GlobalStatic.Direction2D) -> Direction2D:
	match direction:
		GlobalStatic.Direction2D.Up: return GlobalStatic.Direction2D.Down
		GlobalStatic.Direction2D.Right: return GlobalStatic.Direction2D.Left
		GlobalStatic.Direction2D.Down: return GlobalStatic.Direction2D.Up
		GlobalStatic.Direction2D.Left: return GlobalStatic.Direction2D.Right
		_: return GlobalStatic.Direction2D.Down


static func direction2d_is_vertical(direction: GlobalStatic.Direction2D) -> bool:
	return direction == GlobalStatic.Direction2D.Up or direction == GlobalStatic.Direction2D.Down


static func direction2d_is_horizontal(direction: GlobalStatic.Direction2D) -> bool:
	return direction == GlobalStatic.Direction2D.Left or direction == GlobalStatic.Direction2D.Right


static func direction2d_vertical_to_bipolar(direction: GlobalStatic.Direction2D) -> int:
	return 1 if direction == GlobalStatic.Direction2D.Up else -1 if direction == GlobalStatic.Direction2D.Down else 0


static func direction2d_vertical_to_bipolarf(direction: GlobalStatic.Direction2D) -> float:
	return 1.0 if direction == GlobalStatic.Direction2D.Up else -1.0 if direction == GlobalStatic.Direction2D.Down else 0.0


static func direction2d_horizontal_to_bipolar(direction: GlobalStatic.Direction2D) -> int:
	return 1 if direction == GlobalStatic.Direction2D.Right else -1 if direction == GlobalStatic.Direction2D.Left else 0


static func direction2d_horizontal_to_bipolarf(direction: GlobalStatic.Direction2D) -> float:
	return 1.0 if direction == GlobalStatic.Direction2D.Right else -1.0 if direction == GlobalStatic.Direction2D.Left else 0.0


static func direction2d_to_string(direction: Direction2D) -> String:
	return GlobalStatic.Direction2D.keys()[direction]


static func direction2d_turn(base: GlobalStatic.Direction2D, count: int) -> Direction2D:
	return posmod(base + count, 4) as GlobalStatic.Direction2D


static func direction2d_to_vector2i(direction: GlobalStatic.Direction2D) -> Vector2i:
	return Vector2i(
		GlobalStatic.direction2d_horizontal_to_bipolar(direction),
		GlobalStatic.direction2d_vertical_to_bipolar(direction)
	)


static func direction2d_to_vector2(direction: GlobalStatic.Direction2D) -> Vector2:
	return Vector2(
		GlobalStatic.direction2d_horizontal_to_bipolarf(direction),
		GlobalStatic.direction2d_vertical_to_bipolarf(direction)
	)


static func _direction2d_turn_debug() -> bool:
	print("--  start test  --")
	var d = Direction2D.Up
	print(Direction2D.keys()[d])
	d = direction2d_turn(d, 1)
	if d != Direction2D.Right: return false
	print(Direction2D.keys()[d])
	d = direction2d_turn(d, -2)
	if d != Direction2D.Left: return false
	print(Direction2D.keys()[d])
	d = direction2d_turn(d, 7)
	if d != Direction2D.Down: return false
	print(Direction2D.keys()[d])
	d = direction2d_turn(d, 2)
	if d != Direction2D.Up: return false
	print(Direction2D.keys()[d])
	print("--   end test   --")
	return true

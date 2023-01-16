extends Node

signal shake_finished

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var amplitude: Vector2 = Vector2.ZERO
var priority = 0

onready var duration_timer = $Duration
onready var frequency_timer = $Frequency
onready var shake_tween = $Tween

onready var camera = get_parent()

func start(duration: float, frequency: float, amplitude: Vector2, priority: int):
	if priority >= self.priority:
		self.priority = priority
		self.amplitude = amplitude

		duration_timer.wait_time = duration
		frequency_timer.wait_time = 1 / float(frequency)
		duration_timer.start()
		frequency_timer.start()

		_new_shake()
		
		yield(duration_timer, "timeout")
	else:
		emit_signal("shake_finished")

func _new_shake():
	var rand = Vector2()
	rand.x = rand_range(-amplitude.x, amplitude.x)
	rand.y = rand_range(-amplitude.y, amplitude.y)

	shake_tween.interpolate_property(camera, "offset", camera.offset, rand, $Frequency.wait_time, TRANS, EASE)
	shake_tween.start()

func _reset():
	shake_tween.interpolate_property(camera, "offset", camera.offset, Vector2(), $Frequency.wait_time, TRANS, EASE)
	shake_tween.start()

	priority = 0

func _on_Freq_timeout():
	_new_shake()

func _on_Duration_timeout():
	_reset()
	frequency_timer.stop()
	emit_signal("shake_finished")

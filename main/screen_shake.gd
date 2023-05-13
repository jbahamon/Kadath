extends Node

signal shake_finished

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var amplitude: Vector2 = Vector2.ZERO
var priority = 0

@onready var duration_timer = $Duration
@onready var frequency_timer = $Frequency
@onready var shake_tween = get_tree().create_tween()

@onready var camera = get_parent()

func _ready():
	self.shake_tween.stop()
	
func start(duration: float, frequency: float, new_amplitude: Vector2, new_priority: int):
	if new_priority >= self.priority:
		self.priority = new_priority
		self.amplitude = new_amplitude

		duration_timer.wait_time = duration
		frequency_timer.wait_time = 1 / float(frequency)
		duration_timer.start()
		frequency_timer.start()

		_new_shake()
		
		await duration_timer.timeout
	else:
		emit_signal("shake_finished")

func _new_shake():
	var rand = Vector2()
	rand.x = randf_range(-amplitude.x, amplitude.x)
	rand.y = randf_range(-amplitude.y, amplitude.y)
	shake_tween.kill()
	shake_tween.tween_property(camera, "offset", rand, $Frequency.wait_time).set_trans(TRANS).set_ease(EASE)
	shake_tween.play()

func _reset():
	shake_tween.kill()
	shake_tween.tween_property(camera, "offset", Vector2(), $Frequency.wait_time).set_trans(TRANS).set_ease(EASE)
	shake_tween.play()

	priority = 0

func _on_Freq_timeout():
	_new_shake()

func _on_Duration_timeout():
	_reset()
	frequency_timer.stop()
	emit_signal("shake_finished")

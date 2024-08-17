extends Timer

@export var tmin: float = 1.
@export var tmax: float = 2.

var rng: RandomNumberGenerator

func _ready() -> void:
	rng.seed = Time.get_unix_time_from_system()
	wait_time = rng.randf_range(tmin, tmax)

func _on_timeout() -> void:
	wait_time = rng.randf_range(tmin, tmax)
	start()

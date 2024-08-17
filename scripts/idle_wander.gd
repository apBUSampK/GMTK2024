extends Timer

@export var tmin: float = 1.
@export var tmax: float = 2.

func _ready() -> void:
	randomize()
	wait_time = randf_range(tmin, tmax)

func _on_timeout() -> void:
	wait_time = randf_range(tmin, tmax)
	start()

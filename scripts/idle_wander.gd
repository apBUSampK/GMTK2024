extends Timer

@export var tmin: float = 1.
@export var tmax: float = 2.

func Init():
	wait_time = randf_range(tmin, tmax)
	start()

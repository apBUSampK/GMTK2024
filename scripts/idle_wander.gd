extends Timer

@export var tmin: float = 2.
@export var tmax: float = 5.

func Init():
	wait_time = randf_range(tmin, tmax)
	start()

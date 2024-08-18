class_name Food extends StaticBody2D

@onready var calories = randf_range(1, 2)

func Consume() -> float:
	queue_free()
	return calories

extends Node2D

var food = preload("res://scenes/food.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 30:
		var foodInst = food.instantiate()
		foodInst.position = Vector2(randf_range(-512, 512), randf_range(-512, 512))
		add_child(foodInst)
	return

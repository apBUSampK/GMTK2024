extends Node2D

const CAMERA_SPEED = 40

var food = preload("res://scenes/food.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 30:
		var foodInst = food.instantiate()
		foodInst.position = Vector2(randf_range(-512, 512), randf_range(-512, 512))
		add_child(foodInst)
	$PlayerManager.spawn_player(Vector2.ZERO)
	return

func _input(event):
	if not get_tree().paused:
		if event.is_action("ui_up"):
			$Camera2D.position.y -= CAMERA_SPEED
		if event.is_action("ui_down"):
			$Camera2D.position.y += CAMERA_SPEED
		if event.is_action("ui_left"):
			$Camera2D.position.x -= CAMERA_SPEED
		if event.is_action("ui_right"):
			$Camera2D.position.x += CAMERA_SPEED

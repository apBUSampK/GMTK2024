extends Node2D

const CAMERA_SPEED = 40

@export var LVL: int = 0
var food = preload("res://scenes/food.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 30:
		var foodInst = food.instantiate()
		foodInst.position = Vector2(randf_range(-1024, 1024), randf_range(-1024, 1024))
		$FoodContainer.add_child(foodInst)
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
		if event.is_action_pressed("ui_cancel"):
			$Canvas/PauseScreen.show()
			get_tree().paused = true
	else:
		if event.is_action_pressed("ui_cancel") and not $Canvas/MutScreen.visible:
			$Canvas/PauseScreen.hide()
			get_tree().paused = false

func _on_crisis_timer_timeout():
	LVL += 1
	$CrisisTimer.start()

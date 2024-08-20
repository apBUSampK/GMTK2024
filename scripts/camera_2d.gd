extends Camera2D

@export var speed := 300.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cameraSpeed = Vector2.ZERO
	cameraSpeed += Vector2.RIGHT * (Input.get_action_strength("ui_right") - (Input.get_action_strength("ui_left"))) * speed
	cameraSpeed += Vector2.UP * (Input.get_action_strength("ui_up") - (Input.get_action_strength("ui_down"))) * speed
	position += cameraSpeed * delta

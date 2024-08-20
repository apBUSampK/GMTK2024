extends Node2D

const enemy = preload("res://scenes/actors/HostileActor.tscn")

const MUSICA = [
	preload("res://1_Desire_to_Survive.mp3"),
	preload("res://2_Need_to_Adapt.mp3"),
	preload("res://3_Itch_to_Mutate.mp3"),
	preload("res://4_Thirst_to_Expand.mp3")
]

const CRISES = [
	"climate change",
	"enemy spawn",
	"food shortage",
	"climate rapid change"
]

var CrisisFuncs = [
	climate_change,
	enemy_spawn,
	food_shortage,
	climate_rapid
]

var musicLoop: bool = true
var temp: float = 300

@export var lvl: int = 0
var food = preload("res://scenes/food.tscn")

func setCrisis():
	$Camera2D/GetReady.text = "Get ready for\n" + CRISES[lvl] + "\n" + "Temperatue: " + str(int(temp))
	$Music.stream = MUSICA[lvl]
	musicLoop = true
	$Music.play()
	$CrisisTimer.start()

func food_spawn():
	for i in 30:
		var foodInst = food.instantiate()
		foodInst.position = Vector2(randf_range(-1024, 1024), randf_range(-1024, 1024))
		$FoodContainer.add_child(foodInst)

# Called when the node enters the scene tree for the first time.
func _ready():
	setCrisis()
	food_spawn()
	$PlayerManager.spawn_player(Vector2.ZERO, [])
	return

func _unhandled_input(event):
	if not get_tree().paused:
		if event.is_action_pressed("ui_cancel"):
			$Canvas/PauseScreen.show()
			get_tree().paused = true
	else:
		if event.is_action_pressed("ui_cancel") and not $Canvas/MutScreen.visible:
			$Canvas/PauseScreen.hide()
			get_tree().paused = false

func _process(delta):
	var lineLen = $CrisisTimer.time_left / $CrisisTimer.wait_time * 1280
	var pointX = -640 + lineLen
	$Canvas/TimerControl/TimerLine.set_point_position(1, Vector2(pointX, -640))

func climate_change():
	food_spawn()
	temp += randf_range(-20, 80)

func enemy_spawn():
	food_spawn()
	for i in range(5):
		var inst = enemy.instantiate()
		inst.position = Vector2(randf_range(-2048, 2048), randf_range(-2048, 2048))
		add_child(inst)

func food_shortage():
	# No food spawned
	return

func climate_rapid():
	food_spawn()
	temp += randf_range(-40, 100)

func _on_crisis_timer_timeout():
	if lvl < len(CRISES) - 1:
		CrisisFuncs[lvl].call()
		lvl += 1
		musicLoop = false
		await $Music.finished
		setCrisis()

func _on_music_finished():
	if musicLoop:
		$Music.play()

extends Node2D


const DELETE_MARKER_OFFSET = 100.

const PlayerActor = preload("res://scenes/actors/PlayerActor.tscn")

@export var mutScreen: Control

@onready var marker = $Marker
var PlayerAgents: Array[PlayerActor] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func spawn_player(pos: Vector2) -> void:
	var playerActor = PlayerActor.instantiate()
	playerActor.position = pos
	playerActor.mutScreen = mutScreen
	add_child(playerActor)
	PlayerAgents.append(playerActor)
	
	# connect offspring signal
	playerActor.offspring.connect(spawn_player)
	playerActor.died.connect(despawn_player)
	
	# check for 4 players
	if len(agents) >= 4:
		pass

func despawn_player(object: BasicActor):
	agents.erase(object)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("RMB"):
		if (marker.position - event.position).length() > DELETE_MARKER_OFFSET or marker.visible == false:
			marker.position = get_global_mouse_position()
			for agent in PlayerAgents:
				agent.scoutingSet = true
				agent.scoutingPosition = marker.position
		else:
			marker.visible == false
			for agent in PlayerAgents:
				agent.scoutingSet = false

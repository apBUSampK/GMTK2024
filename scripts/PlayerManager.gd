extends Node2D


const DELETE_MARKER_OFFSET = 100.

const PlayerActor = preload("res://scenes/actors/PlayerActor.tscn")
const geneScript = preload("res://scripts/genes.gd")

@export var mutScreen: Control

@onready var marker = $Marker

var agents: Array[PlayerActor] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func spawn_player(pos: Vector2, genes: Array) -> void:
	var playerActor = PlayerActor.instantiate()
	playerActor.position = pos
	playerActor.mutScreen = mutScreen
	
	for newMut in genes:
		var mutName = newMut.get_current_tab_control().name
		#print("Adding ", mutName)
		mutScreen.mutation_change_param(mutName, playerActor.attrs)
		playerActor.Genes.append(geneScript.FromStr(mutName))
	
	add_child(playerActor)
	agents.append(playerActor)
	
	# connect signals
	playerActor.offspring.connect(spawn_player)
	playerActor.died.connect(despawn_player)

func despawn_player(object: BasicActor):
	agents.erase(object)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("RMB"):
		var debug = marker.global_position - get_global_mouse_position()
		if (marker.global_position - get_global_mouse_position()).length() > DELETE_MARKER_OFFSET or marker.visible == false:
			marker.global_position = get_global_mouse_position()
			marker.visible = true
			for agent in agents:
				agent.scoutingSet = true
				agent.scoutingPosition = marker.position
		else:
			marker.visible = false
			for agent in agents:
				agent.scoutingSet = false

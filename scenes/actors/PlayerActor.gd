class_name PlayerActor extends BasicActor

signal offspring(pos: Vector2)

const BASE_HUNGER = .025
const REPRODUCTION_FOOD_LEFTOVER = .5
const RUNAWAY_DIST = 400

var food: float

func setupStateMachine():
	smInst = sm.StateMachine.new(sm.States.IDLE)
	var state_funcs = {
		"IDLE": idle,
		"ATTACKING": attack,
		"FLEEING": flee,
		"REPRODUCING": dummy,
		"SCOUTING": scout,
		"GRABBING": grab,
		"DYING": dummy,
	}
	var set_funcs = {
		"IDLE": oneshot_idle,
		"ATTACKING": set_max_speed,
		"FLEEING": set_max_speed,
		"REPRODUCING": oneshot_reproduce,
		"SCOUTING": set_max_speed,
		"GRABBING": set_max_speed,
		"DYING": oneshot_die,
	}
	smInst.SetFunctions(state_funcs, set_funcs)

func _ready() -> void:
	super()
	# init food
	food = 0.5 * attrs.maxFood.value
	
	# connect signals
	$RndStateUpdate.timeout.connect(_on_rnd_state_update_timeout)
	$ReproductionTimer.timeout.connect(_on_reproduction_timer_timeout)

func idle():
	# passive food consumption
	for index in get_slide_collision_count():
		var collisionObj := get_slide_collision(index).get_collider()
		if collisionObj and collisionObj is Food:
			food += collisionObj.Consume()

func grab() -> Food:
	#print("Grab")
	if not targetObj:
		smInst.SetState(sm.States.IDLE)
		return
	for index in get_slide_collision_count():
		var collisionObj := get_slide_collision(index).get_collider()
		if collisionObj and collisionObj is Food:
			targetObj = null
			smInst.SetState(sm.States.IDLE)
			# consume food
			food += collisionObj.Consume()
			return collisionObj
	return

func _on_reproduction_timer_timeout() -> void:
	food -= attrs.birthFood.value
	smInst.SetState(sm.States.IDLE)
	emit_signal("offspring")

#func _on_detection_body_entered(body: Node2D) -> void:
#	if body is CollisionObject2D and (state == States.IDLE or state == States.INVESTIGATING): # should be food object
#		buff_state = state
#		state = States.GRABBING
#		start_moving(body.position)
#	if body is HostileActor and (state != States.FLEEING and state != States.REPRODUCING and state != States.DYING):
#		buff_state = state
#		state = States.FLEEING
#		start_moving((position - body.position).normalized() * RUNAWAY_DIST)


# If we have enough food, start childbirth. When the timer expires, we will
# spawn a child
func oneshot_reproduce():
	print("Repr")
	print("Start birth")
	desiredPosition = position
	food -= attrs.birthFood.value
	$ReproductionTimer.start()
	

func update_state_rnd():
	match smInst.state:
		sm.States.IDLE:
			if randf_range(0, 10) < attrs.curiosity.value:
				smInst.SetState(sm.States.SCOUTING)
			if randf_range(0, 10) < attrs.fertility.value and food > attrs.birthFood.value + REPRODUCTION_FOOD_LEFTOVER:
				smInst.SetState(sm.States.REPRODUCING)
		_:
			return

func _on_rnd_state_update_timeout() -> void:
	update_state_rnd()
	return

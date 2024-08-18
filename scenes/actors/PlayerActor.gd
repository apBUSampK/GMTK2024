class_name PlayerActor extends BasicActor


signal offspring(pos: Vector2)

const BASE_HUNGER = .025
const REPRODUCTION_FOOD_LEFTOVER = .5
const RUNAWAY_DIST = 400

var buff_state: States

var food: float

func _ready() -> void:
	# init food
	food = 0.5 * stats.maxFood
	
	# connect signals
	$RndStateUpdate.timeout.connect(_on_rnd_state_update_timeout)
	$ReproductionTimer.timeout.connect(_on_reproduction_timer_timeout)
	$Detection.body_entered.connect(_on_detection_body_entered)
	$Grabbing.body_entered.connect(_on_grabbing_body_entered)

func _process(delta: float) -> void:
	food -= BASE_HUNGER * stats.hugerRate * delta
	if food <= 0:
		die()
	
	# Recover state if stopped fleeing
	if state == States.FLEEING and velocity == Vector2.ZERO:
		state = buff_state

func _on_rnd_state_update_timeout() -> void:
	match state:
		States.IDLE:
			if rng.randf() < stats.curiosity:
				state = States.INVESTIGATING
				# investigate()
			if food > stats.birthFood + REPRODUCTION_FOOD_LEFTOVER and rng.randf() < stats.fertility:
				state = States.REPRODUCING
				$ReproductionTimer.start()
		_:
			pass

func _on_reproduction_timer_timeout() -> void:
	start_moving(position)
	food -= stats.birthFood
	state = States.IDLE
	emit_signal("offspring")

func _on_detection_body_entered(body: Node2D) -> void:
	if body is CollisionObject2D and (state == States.IDLE or state == States.INVESTIGATING): # should be food object
		buff_state = state
		state = States.GRABBING
		start_moving(body.position)
	if body is HostileActor and (state != States.FLEEING and state != States.REPRODUCING and state != States.DYING):
		buff_state = state
		state = States.FLEEING
		start_moving((position - body.position).normalized() * RUNAWAY_DIST)

func _on_grabbing_body_entered(body: Node2D) -> void:
	if body is CollisionObject2D and state == States.GRABBING: # should be food object
		food += 5.0 # should depend on food
		state = buff_state

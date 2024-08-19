class_name PlayerActor extends BasicActor

signal offspring(pos: Vector2)

const BASE_HUNGER = .025
const REPRODUCTION_FOOD_LEFTOVER = .5

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
	# set attack_timer
	$AttackTimer.wait_time = 1 / attrs.attackSpeed.value
	
	# init food
	food = 0.5 * attrs.maxFood.value
	
	# connect signals
	$RndStateUpdate.timeout.connect(_on_rnd_state_update_timeout)
	$ReproductionTimer.timeout.connect(_on_reproduction_timer_timeout)
	$detectedStateUpdate.timeout.connect(_on_detected_state_update_timeout)
	$LifeTimer.timeout.connect(_on_life_timer_timeout)

func _process(delta):
	super(delta)
	food -= BASE_HUNGER * attrs.hungerRate.value * delta
	if food > attrs.maxFood.value:
		food = attrs.maxFood.value
	if food <= 0:
		smInst.SetState(sm.States.DYING)

func idle() -> void:
	# passive food consumption
	for index in get_slide_collision_count():
		var collisionObj := get_slide_collision(index).get_collider()
		if collisionObj and collisionObj is Food:
			food += collisionObj.Consume()

func flee() -> void:
	super()
	var heading = Vector2.ZERO
	var detected = $Detection.get_overlapping_bodies()
	for body in detected:
		if body is HostileActor:
			heading += (position - body.position).normalized()
	if heading != Vector2.ZERO:
		desiredPosition = position + heading * FLEE_DIST
	var delta_pos = desiredPosition - position
	if delta_pos.length() > EPS * attrs.movementSpeed.value:
		smInst.SetState(buffState)

func attack() -> void:
	super()
	var hasTarget := false
	for i in get_slide_collision_count():
		var collisionObj := get_slide_collision(i).get_collider()
		if collisionObj is HostileActor:
			if $AttackTimer.is_stopped():
				collisionObj.hp -= attrs.damage.value
				$AttackTimer.start()
			hasTarget = true
			break
	if not hasTarget:
		var detectedBodies = $Detection.get_overlapping_bodies()
		var seeEnemy: bool = false
		for body in detectedBodies:
			if body != self and body is HostileActor:
				seeEnemy = true
				desiredPosition = body.position
				break
		if not seeEnemy:
			smInst.SetState(buffState)

func grab():
	print("Grab")
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
			return
	return

func _on_reproduction_timer_timeout() -> void:
	food -= attrs.birthFood.value
	smInst.SetState(sm.States.IDLE)
	emit_signal("offspring")

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

func _on_detection_body_entered(body) -> void:
	super(body)
	if body is HostileActor:
		react_to_enemy()
	if $detectedStateUpdate.is_stopped():
		$detectedStateUpdate.start()

func _on_detected_state_update_timeout() -> void:
	var detectedBodies = $Detection.get_overlapping_bodies()
	var seeSomething: bool = false
	for body in detectedBodies:
		if body != self:
			seeSomething = true
			if body is HostileActor:
				react_to_enemy()
				break
			if body is Food:
				react_to_food(body)
				break
	if seeSomething:
		$detectedStateUpdate.start()


func _on_life_timer_timeout() -> void:
	smInst.SetState(sm.States.DYING)

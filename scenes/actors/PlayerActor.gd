class_name PlayerActor extends BasicActor
@onready var _animated_sprite = $AnimatedSprite2D

signal offspring(pos: Vector2, genes: Array)

const BASE_HUNGER = .025
const REPRODUCTION_FOOD_LEFTOVER = .5
const SCOUTING_RANDOM_HEADING = PI/10 # divergence to plotted path heading while scouting
const SCOUTING_IDLE_RANGE = 200. # swith to IDLE upon being that close to the marker
const SCOUTING_STEP_MIN = 100.
const SCOUTING_STEP_MAX = 500.

var scoutingPosition: Vector2
var scoutingSet := false

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
		"MERGING": dummy
	}
	var set_funcs = {
		"IDLE": oneshot_idle,
		"ATTACKING": set_max_speed,
		"FLEEING": set_max_speed,
		"REPRODUCING": oneshot_reproduce,
		"SCOUTING": set_max_speed,
		"GRABBING": set_max_speed,
		"DYING": oneshot_die,
		"MERGING": oneshot_merge
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
	var anim = int(get_parent().get_parent().lvl / 2) + 1
	_animated_sprite.play("hero-form-" + str(anim) + "-movement")
	
	var form_changed = food < 7
	if form_changed: # TODO insert form change here.
		_animated_sprite.stop() 
		_animated_sprite.play("hero-form-2-movement")
		
	food -= BASE_HUNGER * attrs.hungerRate.value * delta
	if food > attrs.maxFood.value:
		food = attrs.maxFood.value
	if food <= 0:
		smInst.SetState(sm.States.DYING)

func consume_food():
	# passive food consumption
	for index in get_slide_collision_count():
		var collisionObj := get_slide_collision(index).get_collider()
		if collisionObj and collisionObj is Food:
			food += collisionObj.Consume()

func idle() -> void:
	consume_food()

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

func scout():
	consume_food()
	if not scoutingSet:
		smInst.SetState(sm.States.IDLE)
		return
	var deltaScouting = scoutingPosition - position
	if deltaScouting.length() < SCOUTING_IDLE_RANGE:
		smInst.SetState(sm.States.IDLE)
		return
	if (desiredPosition - position).length() < EPS * attrs.movementSpeed.value:
		desiredPosition = position + deltaScouting.normalized().rotated(
			randf_range(-SCOUTING_RANDOM_HEADING / 2, SCOUTING_RANDOM_HEADING /2)) * randf_range(
				SCOUTING_STEP_MIN, SCOUTING_STEP_MAX
			)

func grab():
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
			return
	return

# If we have enough food, start childbirth. When the timer expires, we will
# spawn a child
func oneshot_reproduce():
	print("Repr")
	print("Start birth")
	desiredPosition = position
	food -= attrs.birthFood.value
	$ReproductionTimer.start()

func oneshot_merge() -> void:
	set_max_speed()
	desiredPosition = Vector2.ZERO

func _on_reproduction_timer_timeout() -> void:
	smInst.SetState(sm.States.IDLE)
	emit_signal("offspring", position, Genes)

func update_state_rnd():
	match smInst.state:
		sm.States.IDLE:
			if randf_range(0, 1) < attrs.curiosity.value:
				smInst.SetState(sm.States.SCOUTING)
				return
			if randf_range(0, 1) < attrs.fertility.value and food > attrs.birthFood.value + REPRODUCTION_FOOD_LEFTOVER:
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
	if smInst.state != sm.States.REPRODUCING and smInst.state != sm.States.DYING and \
	smInst.state != sm.States.MERGING:
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

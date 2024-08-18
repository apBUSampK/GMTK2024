class_name BasicActor extends CharacterBody2D

const EPS = 1e-3

const IDLE_SPEED = .3
const IDLE_WANDER_DIST = 100.
const DYING_SPEED = .1
const BASE_HUNGER = .025
const OFFSPRING_FOOD = .5

const attributor = preload("res://scripts/attributor.gd")
const sm = preload("res://scripts/state_machine.gd")

var attrs = attributor.Attributor.new()
var smInst: sm.StateMachine

var hp: float
var food: float
var cSpeed: float

var rotating = false
var moving = false

var desiredRotation = 0.
var desiredPosition = Vector2.ZERO

func setupStateMachine():
	smInst = sm.StateMachine.new(sm.States.IDLE)
	var state_funcs = {
		"IDLE": idle,
		"ATTACKING": attack,
		"FLEEING": flee,
		"REPRODUCING": reproduce,
		"SCOUTING": scout,
		"GRABBING": grab,
		"DYING": die,
	}
	
	smInst.SetFunctions(state_funcs)

func setupSenseShapes():
	var vConePoints: PackedVector2Array = []
	vConePoints.append(Vector2.ZERO)
	vConePoints.append(Vector2.UP.rotated(-attrs.fieldOfView.value / 2) * attrs.viewRange.value)
	vConePoints.append(Vector2.UP.rotated(attrs.fieldOfView.value / 2) * attrs.viewRange.value)
	var vCone = ConvexPolygonShape2D.new()
	vCone.points = vConePoints
	$Detection/VisionCone.shape = vCone
	
	$Detection/SenseCircle.shape.set_radius(attrs.senseRadius.value)

func start_rotation(newDesiredRotation):
	if (newDesiredRotation != rotation):
		self.desiredRotation = newDesiredRotation
		rotating = true

func start_moving(newDesiredPosition):
	if (newDesiredPosition != position):
		self.desiredPosition = newDesiredPosition
		moving = true

func idle():
	print("Idle")

func attack():
	print("Attack")

func flee():
	print("Flee")

func reproduce():
	print("Repr")

func scout():
	print("Scout")

func grab():
	print("Grab")

func die():
	smInst.SetState(sm.States.DYING)
	$DeathTimer.start()

func _ready():
	# Randomize RNG
	randomize()
	
	# Initialize stateMachine
	setupStateMachine()
	
	# Set up sense shapes
	setupSenseShapes()
	
	# Init hp and food
	hp = attrs.maxHp.value
	cSpeed = IDLE_SPEED * attrs.movementSpeed.value
	food = attrs.maxFood.value / 2.0
	
	# Start LifeTimer
	$LifeTimer.wait_time = attrs.lifeTime.value
	$LifeTimer.start()

func _process(delta):
	food -= BASE_HUNGER * attrs.hungerRate.value * delta
	if food <= 0 or hp < attrs.maxHp.value:
		smInst.SetState(sm.States.DYING)

func _physics_process(delta):
	if moving:
		var heading = desiredPosition - position
		start_rotation(heading.angle_to(Vector2.UP))
		if not rotating:
			velocity = heading.normalized() * cSpeed
	if rotating:
		if rotation != desiredRotation:
			rotate(attrs.turnSpeed.value * delta)
		else:
			rotating = false
	if (desiredPosition - position).length() < EPS:
		velocity = Vector2.ZERO
		moving = false
	
	move_and_slide()

func _on_rnd_state_update_timeout() -> void:
	match smInst.state:
		sm.States.IDLE:
			if randf() < attrs.curiosity.value:
				smInst.SetState(sm.States.SCOUTING)
			if food > attrs.birthFood.value + OFFSPRING_FOOD and randf() < attrs.fertility.value:
				smInst.SetState(sm.States.REPRODUCING)
				$ReproductionTimer.start()
		_:
			pass

func _on_idle_wander_timeout() -> void:
	if smInst.state == sm.States.IDLE:
		start_moving(position + Vector2.UP.rotated(randf_range(0, 2*PI)) * IDLE_WANDER_DIST)
	else:
		$IdleWander.stop()

func _on_reproduction_timer_timeout() -> void:
	food -= attrs.birthFood.value
	smInst.SetState(sm.States.IDLE)

func _on_life_timer_timeout() -> void:
	smInst.SetState(sm.States.DYING)

func _on_detection_body_entered(body: Node2D) -> void:
	if body is BasicActor:
		pass

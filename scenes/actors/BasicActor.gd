class_name BasicActor extends CharacterBody2D

const EPS = 1.0

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
	var vConePoints: PackedVector2Array = [
		Vector2.ZERO,
		Vector2.RIGHT.rotated(-attrs.fieldOfView.value / 2) * attrs.viewRange.value,
		Vector2.RIGHT.rotated(attrs.fieldOfView.value / 2) * attrs.viewRange.value
	]
	
	# TODO: remove!!! Debug only
	$Detection/DebugLine.points = vConePoints
	$Detection/DebugLine.add_point(Vector2.ZERO)
	
	var vCone = ConvexPolygonShape2D.new()
	vCone.points = vConePoints
	$Detection/VisionCone.shape = vCone
	
	$Detection/SenseCircle.shape.set_radius(attrs.senseRadius.value)

func idle():
	# print("Idle")
	return

func attack():
	print("Attack")
	return

func flee():
	print("Flee")
	return

# If we have enough food, start childbirth. When the timer expires, we will
# spawn a child
func reproduce():
	print("Repr")
	if food > attrs.birthFood.value + OFFSPRING_FOOD:
		food -= attrs.birthFood.value
		$ReproductionTimer.start()
	smInst.SetState(sm.States.IDLE)

func scout():
	print("Scout")
	smInst.SetState(sm.States.IDLE)
	return

func grab():
	print("Grab")
	return

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
	
	# Start Wandering
	$IdleWander.Init()

# Update food and run state machine process
func update(delta):
	food -= BASE_HUNGER * attrs.hungerRate.value * delta
	if food <= 0 or hp < attrs.maxHp.value:
		smInst.SetState(sm.States.DYING)
	
	# Main state machine loop
	smInst.process()

func _process(delta):
	update(delta)

func rotate_to_face(pos) -> bool:
	var delta_angle = position.angle_to_point(pos) - rotation
	if delta_angle > attrs.turnSpeed.value:
		rotate(attrs.turnSpeed.value)
		return true
	if delta_angle < -attrs.turnSpeed.value:
		rotate(-attrs.turnSpeed.value)
		return true
	return false

# Move towards delta_pos
func move(delta_pos):
	var dir = delta_pos.normalized()
	move_and_collide(dir * cSpeed)

# Rotate to face the position, then move towards it
func _physics_process(delta):
	var delta_pos = desiredPosition - position
	if delta_pos.length() > EPS:
		if not rotate_to_face(desiredPosition):
			move(delta_pos)

func update_state_rnd():
	match smInst.state:
		sm.States.IDLE:
			if randf_range(0, 10) < attrs.curiosity.value:
				smInst.SetState(sm.States.SCOUTING)
			if randf_range(0, 10) < attrs.fertility.value:
				smInst.SetState(sm.States.REPRODUCING)
		_:
			return

func _on_rnd_state_update_timeout() -> void:
	update_state_rnd()
	return

func _on_idle_wander_timeout() -> void:
	# Update desired position in idle wandering
	if smInst.state == sm.States.IDLE:
		desiredPosition = position + Vector2.UP.rotated(randf_range(0, 2*PI)) * IDLE_WANDER_DIST
		$"../Line2D".add_point(desiredPosition)
		$IdleWander.Init()
	return

func _on_reproduction_timer_timeout() -> void:
	# Reproduction state ended, here we will spawn a child
	return

func _on_life_timer_timeout() -> void:
	# Maximum life time expired
	smInst.SetState(sm.States.DYING)
	return

func _on_detection_body_entered(body: Node2D) -> void:
	if body == self:
		return
	print(body)

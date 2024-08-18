class_name BasicActor extends CharacterBody2D

const EPS = 1e-2

const IDLE_SPEED = .3
const IDLE_WANDER_DIST = 250.
const DYING_SPEED = .1

const attributor = preload("res://scripts/attributor.gd")
const sm = preload("res://scripts/state_machine.gd")
const child = preload("res://scenes/actors/BasicActor.tscn")

var attrs: attributor.Attributor
var smInst: sm.StateMachine

var hp: float
var cSpeed: float
var desiredPosition = Vector2.ZERO
# The only object our creature can keep in memory.
# This will be the enemy we're avoiding, or the food we want to grab
var targetObj: CollisionObject2D

func setupStateMachine():
	smInst = sm.StateMachine.new(sm.States.IDLE)
	var state_funcs = {
		"IDLE": dummy,
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
		"REPRODUCING": dummy,
		"SCOUTING": set_max_speed,
		"GRABBING": set_max_speed,
		"DYING": oneshot_die,
	}
	smInst.SetFunctions(state_funcs, set_funcs)

func setupSenseShapes():
	var vConePoints: PackedVector2Array = [
		Vector2.ZERO,
		Vector2.RIGHT.rotated(-attrs.fieldOfView.value / 2) * attrs.viewRange.value,
		Vector2.RIGHT.rotated(attrs.fieldOfView.value / 2) * attrs.viewRange.value
	]
	
	var vCone = ConvexPolygonShape2D.new()
	vCone.points = vConePoints
	$Detection/VisionCone.shape = vCone
	
	$Detection/SenseCircle.shape.set_radius(attrs.senseRadius.value)

# dummy function for state mahine
func dummy():
	pass

func oneshot_idle():
	cSpeed = IDLE_SPEED * attrs.movementSpeed.value
	$IdleWander.Init()
	return

func set_max_speed():
	cSpeed = attrs.movementSpeed.value
	return

func attack():
	print("Attack")
	return

func grab() -> Food:
	#print("Grab")
	if not targetObj:
		smInst.SetState(sm.States.IDLE)
		return null
	for index in get_slide_collision_count():
		var collisionObj := get_slide_collision(index).get_collider()
		if collisionObj and collisionObj is Food:
			targetObj = null
			smInst.SetState(sm.States.IDLE)
			return collisionObj
	return null

func flee():
	print("Flee")
	return

func scout():
	print("Scout")
	smInst.SetState(sm.States.IDLE)
	return

func oneshot_die():
	cSpeed = DYING_SPEED * attrs.movementSpeed.value
	smInst.SetState(sm.States.DYING)
	$DeathTimer.start()

func _init(attrs_ = attributor.Attributor.new()):
	# Set attributes
	attrs = attrs_
	
	# Initialize stateMachine
	setupStateMachine()

func _ready():
	# Randomize RNG
	randomize()
	
	# Set up sense shapes
	setupSenseShapes()
	
	# Init hp and food
	hp = attrs.maxHp.value
	cSpeed = IDLE_SPEED * attrs.movementSpeed.value
	
	# Start Wandering
	$IdleWander.Init()
	
	# Connect Signals
	$IdleWander.timeout.connect(_on_idle_wander_timeout)
	$Detection.body_entered.connect(_on_detection_body_entered)

func update(delta):	
	# Main state machine loop
	smInst.process()
	print(smInst.state)

func _process(delta):
	update(delta)

func rotate_to_face(delta, pos) -> bool:
	var delta_angle = position.angle_to_point(pos) - rotation
	if delta_angle > EPS * attrs.turnSpeed.value:
		rotate(attrs.turnSpeed.value * delta)
		return true
	if delta_angle < -EPS * attrs.turnSpeed.value:
		rotate(-attrs.turnSpeed.value * delta)
		return true
	return false

# Move towards delta_pos
func move(delta_pos):
	var dir = delta_pos.normalized()
	velocity = dir * cSpeed
	move_and_slide()

# Rotate to face the position, then move towards it
func _physics_process(delta):
	var delta_pos = desiredPosition - position
	if delta_pos.length() > EPS * attrs.movementSpeed.value:
		if not rotate_to_face(delta, desiredPosition):
			move(delta_pos)

func _on_idle_wander_timeout() -> void:
	# Update desired position in idle wandering
	if smInst.state == sm.States.IDLE:
		desiredPosition = position + Vector2.UP.rotated(randf_range(0, 2*PI)) * IDLE_WANDER_DIST
		$"../Line2D".add_point(desiredPosition)
		$IdleWander.Init()
	return

func _on_detection_body_entered(body: Node2D) -> void:
	if body == self:
		return
	if body is Food and not targetObj:
		smInst.SetState(sm.States.GRABBING)
		desiredPosition = body.position
		targetObj = body
		return

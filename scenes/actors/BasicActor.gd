class_name BasicActor extends CharacterBody2D

const EPS = 1e-3

const IDLE_SPEED = .3
const IDLE_WANDER_DIST = 100.
const DYING_SPEED = .1
const BASE_HUNGER = .025
const OFFSPRING_FOOD = .5

const attributor = preload("res://scripts/attributor.gd")
const stateMachine = preload("res://scripts/state_machine.gd")

var stats = attributor.Attributor.new()
var stateMachInst = stateMachine.StateMachine.new(stateMachine.States.IDLE)
var state: stateMachine.States = stateMachine.States.IDLE

var hp: float
var food: float
var cSpeed: float

var rotating = false
var moving = false

var desiredRotation = 0.
var desiredPosition = Vector2.ZERO

func start_rotation(newDesiredRotation):
	if (newDesiredRotation != rotation):
		self.desiredRotation = newDesiredRotation
		rotating = true

func start_moving(newDesiredPosition):
	if (newDesiredPosition != position):
		self.desiredPosition = newDesiredPosition
		moving = true

func die():
	state = stateMachine.States.DYING
	$DeathTimer.start()

func _ready():
	# seed rng
	randomize()
	
	# change stats due to genes
	$LifeTimer.wait_time = stats.lTime
	
	# set up sense shapes
	var vConePoints: PackedVector2Array
	vConePoints.append(Vector2.ZERO)
	vConePoints.append(Vector2.UP.rotated(-stats.fov/2) * stats.vRange)
	vConePoints.append(Vector2.UP.rotated(stats.fov/2) * stats.vRange)
	var vCone = ConvexPolygonShape2D.new()
	vCone.points = vConePoints
	$Detection/VisionCone.shape = vCone
	
	$Detection/SenseCircle.shape.set_radius(stats.senseRadius)
	
	# init hp and food
	hp = stats.mhp
	cSpeed = IDLE_SPEED * stats.speed
	food = stats.maxFood / 2
	$LifeTimer.start()

func _process(delta):
	food -= BASE_HUNGER * stats.hungerRate * delta
	if food <= 0 or hp < stats.mhp:
		die()

func _physics_process(delta):
	if moving:
		var heading = desiredPosition - position
		start_rotation(heading.angle_to(Vector2.UP))
		if not rotating:
			velocity = heading.normalized() * cSpeed
	if rotating:
		if rotation != desiredRotation:
			rotate(stats.phiSpeed * delta)
		else:
			rotating = false
	if (desiredPosition - position).length() < EPS:
		velocity = Vector2.ZERO
		moving = false
	
	move_and_slide()

func _on_rnd_state_update_timeout() -> void:
	match state:
		stateMachine.States.IDLE:
			print("Idle")
			if randf() < stats.curiosity:
				state = stateMachine.States.SCOUTING
				# investigate()
			if food > stats.birthFood + OFFSPRING_FOOD and randf() < stats.fertility:
				state = stateMachine.States.REPRODUCING
				$ReproductionTimer.start()
		_:
			pass

func _on_idle_wander_timeout() -> void:
	if state == stateMachine.States.IDLE:
		start_moving(position + Vector2.UP.rotated(randf_range(0, 2*PI)) * IDLE_WANDER_DIST)
	else:
		$IdleWander.stop()

func _on_reproduction_timer_timeout() -> void:
	food -= stats.birthFood
	state = stateMachine.States.IDLE

func _on_life_timer_timeout() -> void:
	die()

func _on_detection_body_entered(body: Node2D) -> void:
	if body is BasicActor:
		pass

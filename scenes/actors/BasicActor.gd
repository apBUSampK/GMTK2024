extends CharacterBody2D

const EPS = 1e-3

const IDLE_SPEED = .3
const IDLE_WANDER_DIST = 100.
const DYING_SPEED = .1
const BASE_HUNGER = .025
const OFFSPRING_FOOD = .5

var rng: RandomNumberGenerator

var stats = preload("res://scripts/attributor.gd").new()

var hp: float
var food: float
var cSpeed: float

enum States {
	IDLE,
	ATTACKING,
	FLEEING,
	REPRODUCING,
	INVESTIGATING,
	GRABBING,
	DYING
	#more?
}

var state: States = States.IDLE

var rotating = false
var moving = false

var desiredRotation = 0.
var desiredPosition = Vector2.ZERO

func start_rotation(desiredRotation):
	if (desiredRotation != rotation):
		self.desiredRotation = desiredRotation
		rotating = true

func start_moving(desiredPosition):
	if (desiredPosition != position):
		self.desiredPosition = desiredPosition
		moving = true

func die():
	state = States.DYING
	$DeathTimer.start()

func _ready():
	# seed rng
	rng.seed = Time.get_unix_time_from_system()
	
	# change stats due to genes
	$LifeTimer.wait_time = stats.lTime
	
	# set up sense shapes
	var vConePoints: PackedVector2Array
	vConePoints.append(Vector2.ZERO)
	vConePoints.append(Vector2.UP.rotated(-stats.fov/2) * stats.vRange)
	vConePoints.append(Vector2.UP.rotated(stats.fov/2) * stats.vRange)
	var vCone: ConvexPolygonShape2D
	vCone.points = vConePoints
	$VisionCone/CollisionShape2D.shape = vCone
	
	$SenseCircle/CollisionShape2D.shape.set_radius(stats.senseRadius)
	
	# init hp and food
	hp = stats.mhp
	cSpeed = IDLE_SPEED * stats.speed
	food = stats.maxFood / 2

func _on_rnd_state_update_timeout() -> void:
	match state:
		States.IDLE:
			if rng.randf() < stats.curiosity:
				state = States.INVESTIGATING
				# investigate()
			if food > stats.birthFood + OFFSPRING_FOOD and rng.randf() < stats.fertility:
				state = States.REPRODUCING
				$ReproductionTimer.start()
		_:
			pass

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
	if (desiredPosition - position).length < EPS:
		velocity = Vector2.ZERO
		moving = false
		
	move_and_slide()


func _on_idle_wander_timeout() -> void:
	if state == States.IDLE:
		start_moving(position + Vector2.UP.rotated(rng.randf_range(0, 2*PI)) * IDLE_WANDER_DIST)
	else:
		$IdleWander.stop()

func _on_reproduction_timer_timeout() -> void:
	food -= stats.birthFood
	state = States.IDLE

func _on_life_timer_timeout() -> void:
	die()

class_name BasicActor extends CharacterBody2D

const EPS = 1e-3

const IDLE_SPEED = .3
const IDLE_WANDER_DIST = 100.
const DYING_SPEED = .1

var rng: RandomNumberGenerator

const Attributor = preload("res://scripts/attributor.gd")
var stats: Attributor

var hp: float
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

func _init(stats: Attributor = Attributor.new()) -> void:
	self.stats = stats

func start_rotation(desiredRotation) -> void:
	if (desiredRotation != rotation):
		self.desiredRotation = desiredRotation
		rotating = true

func start_moving(desiredPosition) -> void:
	if (desiredPosition != position):
		self.desiredPosition = desiredPosition
		moving = true

func die() -> void:
	state = States.DYING
	$DeathTimer.start()

func _ready():
	# seed rng
	rng.randomize()
	
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
	
	# connect signals
	$IdleWander.timeout.connect(_on_idle_wander_timeout)



func _process(delta):
	if hp < stats.maxhp:
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

extends CharacterBody2D

const EPS = 1e-3

@export var mhp = 200
var hp = mhp
@export var dmg = 20
@export var speed = 300.
@export var phiSpeed = 2.

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

func _physics_process(delta):
	if moving:
		var heading = desiredPosition - position
		start_rotation(heading.angle_to(Vector2.UP))
		if not rotating:
			velocity = heading.normalized() * speed
	if rotating:
		if rotation != desiredRotation:
			rotate(phiSpeed * delta)
		else:
			rotating = false
	if (desiredPosition - position).length < EPS:
		velocity = Vector2.ZERO
		moving = false
		
	move_and_slide()

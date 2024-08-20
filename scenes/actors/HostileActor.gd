class_name HostileActor extends BasicActor
@onready var _animated_sprite = $AnimatedSprite2D

func _process(delta):
	super(delta)
	_animated_sprite.play("movement")

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	attrs.guts.value=1
	attrs.aggression.value=1
	# connect signals
	$detectedStateUpdate.timeout.connect(_on_detected_state_update_timeout)

func _on_detection_body_entered(body) -> void:
	if body is PlayerActor:
		react_to_enemy()
	if $detectedStateUpdate.is_stopped():
		$detectedStateUpdate.start()

func _on_detected_state_update_timeout() -> void:
	var detectedBodies = $Detection.get_overlapping_bodies()
	var seeSomething: bool = false
	for body in detectedBodies:
		if body != self:
			seeSomething = true
			if body is PlayerActor:
				react_to_enemy()
				break
	if seeSomething:
		$detectedStateUpdate.start()

func attack() -> void:
	super()
	var hasTarget := false
	for i in get_slide_collision_count():
		var collisionObj := get_slide_collision(i).get_collider()
		if collisionObj is PlayerActor:
			if $AttackTimer.is_stopped():
				collisionObj.hp -= attrs.damage.value
				$AttackTimer.start()
			hasTarget = true
			break
	if not hasTarget:
		var detectedBodies = $Detection.get_overlapping_bodies()
		var seeEnemy: bool = false
		for body in detectedBodies:
			if body != self and body is PlayerActor:
				seeEnemy = true
				desiredPosition = body.position
				break
		if not seeEnemy:
			smInst.SetState(buffState)

func flee() -> void:
	super()
	var heading = Vector2.ZERO
	var detected = $Detection.get_overlapping_bodies()
	for body in detected:
		if body is PlayerActor:
			heading += (position - body.position).normalized()
	if heading != Vector2.ZERO:
		desiredPosition = position + heading * FLEE_DIST
	elif (desiredPosition - position).length() < EPS * attrs.movementSpeed.value:
		smInst.SetState(buffState)

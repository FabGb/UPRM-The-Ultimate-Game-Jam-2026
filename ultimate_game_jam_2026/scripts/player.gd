extends CharacterBody2D

#--------VARIABLES--------#
var speed = 100.0
var accel = speed
var decel = 3 * speed
var jumpVelocity = -200.0
var health = 100
var attack = 15
var gotPhonePowerUp = false
var gotCarPowerUp = false
var hasPhone = false
var hasCar = false

var timer = 0
var iFrames = 10

var facingRight = false
var facingLeft = false
var knockback = false
var knockbackTime = 0
var force = Vector2(3, 3)

var isDashing = false
var dashTime = 0
var dashSpeed = 3 * speed
var dashDir = 0

@onready var player_sprite = $AnimatedSprite2D
@onready var attackArea = $AttackArea

func sign(num: float) -> int:
	if num >= 0:
		return 1
	else:
		return -1

#--------BUILT-IN FUNCTIONS--------#
func _ready() -> void:
	$AttackArea.scale = Vector2(1, 1)
	$AttackArea/CollisionShape2D.scale = Vector2(1, 1)

	var shape = CircleShape2D.new()
	shape.radius = 10
	$AttackArea/CollisionShape2D.shape = shape

	add_to_group("Player")
	attackArea.get_node("CollisionShape2D").disabled = true

func _physics_process(delta: float) -> void:
	movement(delta)
	powerUpCollisions()

	if iFrames > 0:
		iFrames -= 1

#--------CUSTOM FUNCTIONS--------#
func movement(delta):
	if timer <= 0:
		attackArea.get_node("CollisionShape2D").disabled = true
	else:
		timer -= 1

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if knockbackTime > 0:
		knockbackTime -= 1

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jumpVelocity

	var direction := Input.get_axis("ui_left", "ui_right")

	if isDashing:
		dashTime -= 1
		velocity.x = dashDir * dashSpeed

		if dashTime <= 0:
			isDashing = false
			velocity.x = speed * direction

		move_and_slide()
		return

	if direction < 0:
		facingLeft = true
		facingRight = false
	elif direction > 0:
		facingRight = true
		facingLeft = false

	if direction != 0:
		var target_speed = speed * direction

		if sign(velocity.x) != sign(direction) and velocity.x != 0:
			velocity.x = move_toward(velocity.x, 0, decel * delta)
		else:
			velocity.x = move_toward(velocity.x, target_speed, accel * delta)

		if Input.is_action_just_pressed("Dash") and not isDashing:
			isDashing = true
			dashTime = 10
			if direction != 0:
				dashDir = direction
			else:
				if facingRight:
					dashDir = 1
				else:
					dashDir = -1
			velocity.x = dashDir * dashSpeed

			if not hasPhone:
				attackArea.get_node("CollisionShape2D").disabled = false
				timer = 10
				iFrames = 20

	else:
		velocity.x = move_toward(velocity.x, 0, decel * delta)

		if Input.is_action_just_pressed("Dash") and not isDashing:
			isDashing = true
			dashTime = 10
			if facingRight:
				dashDir = 1
			else:
				dashDir = -1
			velocity.x = dashDir * dashSpeed

	if knockback:
		velocity = Vector2(-sign(velocity.x) * 20, -100)
		knockback = false
		knockbackTime = 10

	move_and_slide()
	flip_player()

func flip_player():
	if knockbackTime % 10 > 5:
		$AnimatedSprite2D.modulate = Color(1, 0, 0)
	else:
		$AnimatedSprite2D.modulate = Color(1, 1, 1)
	
	if velocity.x < 0:
		player_sprite.flip_h = true
	elif velocity.x > 0:
		player_sprite.flip_h = false

func powerUpCollisions() -> void:
	var direction := Input.get_axis("ui_left", "ui_right")

	if Input.is_action_just_pressed("Power_Use") and hasPhone:
		phoneAttack()
	
	if Input.is_action_pressed("Power_Use") and hasCar:
		speed = speed * 2
		accel = accel * 2
		carAttack()
		attackArea.get_node("CollisionShape2D").disabled = false

	if Input.is_action_just_released("Power_Use") and hasCar:
		speed = speed / 2
		accel = accel / 2
		attackArea.get_node("CollisionShape2D").disabled = true

	if Input.is_action_just_pressed("Remove_Power") and (hasPhone or hasCar):
		$AttackArea.scale = Vector2(1, 1)
		$AttackArea/CollisionShape2D.scale = Vector2(1, 1)

		var shape = CircleShape2D.new()
		shape.radius = 10
		$AttackArea/CollisionShape2D.shape = shape
		scale = Vector2(1, 1)
		force = Vector2(1, 1)
		attack = 15
		speed = 100
		accel = speed
		decel = 3 * speed
		hasPhone = false

	if gotPhonePowerUp:
		$AttackArea.scale = Vector2(1, 2)
		$AttackArea/CollisionShape2D.scale = Vector2(1, 2)

		var shape = RectangleShape2D.new()
		shape.size = Vector2(10, 8)
		$AttackArea/CollisionShape2D.shape = shape

		scale = Vector2(1, 2)
		force = Vector2(1, 1)

		attack = 30
		gotPhonePowerUp = false
		hasPhone = true
		hasCar = false 		# override power up if collected
	
	if gotCarPowerUp:
		$AttackArea.scale = Vector2(2, 1)
		$AttackArea/CollisionShape2D.scale = Vector2(2, 1)

		var shape = RectangleShape2D.new()
		shape.size = Vector2(3, 10)
		$AttackArea/CollisionShape2D.shape = shape

		scale = Vector2(2, 1)
		force = Vector2(10, 1)

		attack = 25
		speed = speed * 1.5
		accel = accel * 1.2
		decel = decel * 1.35
		hasPhone = false 	# override power up if collected
		gotCarPowerUp = false
		hasCar = true

func phoneAttack() -> void:
	var size = ($CollisionShape2D.shape as CircleShape2D).radius
	var offset = Vector2(2 * size, -size)

	if facingLeft:
		offset.x = -offset.x

	attackArea.position = offset

	attackArea.get_node("CollisionShape2D").disabled = false
	await get_tree().create_timer(0.2).timeout
	attackArea.get_node("CollisionShape2D").disabled = true

func carAttack() -> void:
	var size = ($CollisionShape2D.shape as CircleShape2D).radius
	var offset = Vector2(size, 0)

	if facingLeft:
		offset.x = -offset.x

	attackArea.position = offset

func takeDamage(damage: float) -> void:
	if iFrames <= 0:
		health -= damage
		iFrames = 20
		knockback = true

#--------SIGNALS--------#

extends CharacterBody2D

#--------VARIABLES--------#
var speed = 90.0
var jumpVelocity = -200.0
var health = 100
var attack = 15
var gotPhonePowerUp = false
var hasPhone = false

var timer = 0
var iFrames = 10

@onready var player_sprite = $AnimatedSprite2D
@onready var attackArea = $AttackArea

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

	 #Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jumpVelocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
		if Input.is_action_just_pressed("Dash"):
			velocity.x = direction * (speed * 15)
			attackArea.get_node("CollisionShape2D").disabled = false
			timer = 10
			iFrames = 20

	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if Input.is_action_just_pressed("Dash"):
			velocity.x = move_toward(velocity.x, 0, speed * 15)

	move_and_slide()
	flip_player()

func flip_player():
	if velocity.x < 0:
		player_sprite.flip_h = true
	elif velocity.x > 0:
		player_sprite.flip_h = false

func powerUpCollisions() -> void:
	var direction := Input.get_axis("ui_left", "ui_right")

	if Input.is_action_just_pressed("Power_Use") and hasPhone:
		phoneAttack(direction)
	
	if Input.is_action_just_pressed("Remove_Power") and hasPhone:
		$AttackArea.scale = Vector2(1, 1)
		$AttackArea/CollisionShape2D.scale = Vector2(1, 1)

		var shape = CircleShape2D.new()
		shape.radius = 10
		$AttackArea/CollisionShape2D.shape = shape
		scale = Vector2(1, 1)
		hasPhone = false

	if gotPhonePowerUp:
		$AttackArea.scale = Vector2(1, 2)
		$AttackArea/CollisionShape2D.scale = Vector2(1, 2)

		var shape = RectangleShape2D.new()
		shape.size = Vector2(10, 8)
		$AttackArea/CollisionShape2D.shape = shape

		scale = Vector2(2, 2)

		gotPhonePowerUp = false
		hasPhone = true

func phoneAttack(direction: float) -> void:
	var size = ($CollisionShape2D.shape as CircleShape2D).radius
	var offset = Vector2(2 * size, -size)

	if direction < 0:
		offset.x = -offset.x

	attackArea.position = offset

	attackArea.get_node("CollisionShape2D").disabled = false
	await get_tree().create_timer(0.2).timeout
	attackArea.get_node("CollisionShape2D").disabled = true

func takeDamage(damage: float) -> void:
	if iFrames <= 0:
		health -= damage
		iFrames = 20
		print(health)

#--------SIGNALS--------#

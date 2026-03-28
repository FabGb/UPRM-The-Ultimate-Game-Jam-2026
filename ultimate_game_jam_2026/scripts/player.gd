extends CharacterBody2D


const SPEED = 90.0
const JUMP_VELOCITY = -200.0
@onready var attackArea = $PhoneAttackArea

var gotPhonePowerUp = false
var hasPhone = false

func _ready() -> void:
	attackArea.monitoring = false
	attackArea.visible = false
	attackArea.get_node("CollisionShape2D").disabled = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if Input.is_action_just_pressed("Dash"):
			velocity.x = direction * (SPEED*15)

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if Input.is_action_just_pressed("Dash"):
			velocity.x = move_toward(velocity.x,0,SPEED*15)

	if Input.is_action_just_pressed("Power_Use") and hasPhone:
		print("Attack")
		attack(direction)

	if gotPhonePowerUp:
		# Changes the shape of the hitbox of the player to a rectangle; useful when turning into a phone
		# var shape_node = get_node("CollisionShape2D")

		# var new_shape = RectangleShape2D.new()
		# new_shape.size = Vector2(50, 20)

		# shape_node.set_deferred("shape", new_shape)

		# Temporary differences
		scale = Vector2(2, 2)

		gotPhonePowerUp = false
		hasPhone = true
		print("Changed shape")




	move_and_slide()


func attack(direction: float) -> void:
	var size = ($CollisionShape2D.shape as CircleShape2D).radius
	var offset = Vector2(2 * size, -size)

	if direction < 0:
		offset.x = -offset.x

	attackArea.position = offset

	attackArea.monitoring = true
	attackArea.visible = true
	attackArea.get_node("CollisionShape2D").disabled = false
	await get_tree().create_timer(0.2).timeout
	attackArea.monitoring = false
	attackArea.visible = false
	attackArea.get_node("CollisionShape2D").disabled = true
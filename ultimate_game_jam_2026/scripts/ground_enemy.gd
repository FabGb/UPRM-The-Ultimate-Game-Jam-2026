extends CharacterBody2D

var speed = 250.0
var health = 40
var attack = 15
var playerRef
var direction = -1
var directionTimer = 60

var knockback = false
var knockbackTime = 0

@onready var deadSound = preload("res://assets/Sounds/enemy_death.MP3")

func sign(num: float) -> int:
	if num >= 0:
		return 1
	else:
		return -1

func _ready() -> void:
	playerRef = get_tree().get_nodes_in_group("Player")[0]
	health += ceil(($CollisionShape2D.shape as CircleShape2D).radius) * 5

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if health <= 0:
		SoundManager.play_sound_global(deadSound, position)
		queue_free()

	if knockbackTime > 0:
		knockbackTime -= 1
		$AnimatedSprite2D.modulate = Color(1, 0, 0)

	else:
		$AnimatedSprite2D.modulate = Color(1, 1, 1)
		if abs(playerRef.position.x - position.x) < 500 and abs(playerRef.position.y - position.y) < 30:
			direction = sign(playerRef.position.x - position.x)
		else:
			directionTimer -= 1
			if directionTimer <= 0:
				directionTimer = 120
				direction *= -1

		velocity.x = speed * direction

		if knockback:
			velocity = Vector2(-sign(velocity.x) * speed * playerRef.force.x, -speed * playerRef.force.y)
			knockback = false
			knockbackTime = 10

	move_and_slide()


func _on_killable_area_entered(area: Area2D) -> void:
	health -= playerRef.attack
	knockback = true


func _on_killable_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		playerRef.takeDamage(attack)

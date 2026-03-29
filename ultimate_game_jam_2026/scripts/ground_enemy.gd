extends CharacterBody2D

var speed = 50.0
var health = 50
var attack = 10
var playerRef
var direction = -1
var directionTimer = 120

func sign(num: float) -> int:
	if num >= 0:
		return 1
	else:
		return -1

func _ready() -> void:
	playerRef = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta: float) -> void:
	if abs(playerRef.position.x - position.x) < 100:
		direction = sign(playerRef.position.x - position.x)
	else:
		directionTimer -= 1
		if directionTimer <= 0:
			directionTimer = 120
			direction *= -1

	velocity.x = speed * direction

	if health <= 0:
		queue_free()

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	
	move_and_slide()


func _on_killable_area_entered(area: Area2D) -> void:
	health -= playerRef.attack


func _on_killable_body_entered(body: Node2D) -> void:
	playerRef.takeDamage(attack)

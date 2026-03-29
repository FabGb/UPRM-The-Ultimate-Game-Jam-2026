extends CharacterBody2D

var speed = 25.0
var health = 50
var attack = 10
var playerRef
var baseDirection = -1
var directionTimer = 120
var angle = 0

func getDistance(target: Vector2) -> float:
	return sqrt(pow(target.x - position.x, 2) + pow(target.y - position.y, 2))

func sign(num: float) -> int:
	if num >= 0:
		return 1
	else:
		return -1

func _ready() -> void:
	playerRef = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta: float) -> void:
	if getDistance(playerRef.position) < 100:
		angle = atan2(playerRef.position.y - position.y, playerRef.position.x - position.x)
		velocity.x = speed * cos(angle)
		velocity.y = speed * sin(angle)
	else:
		velocity.x = speed * baseDirection
		directionTimer -= 1
		if directionTimer <= 0:
			directionTimer = 120
			baseDirection *= -1

	if health <= 0:
		queue_free()

	move_and_slide()

func _on_killable_area_entered(area: Area2D) -> void:
	health -= playerRef.attack


func _on_killable_body_entered(body: Node2D) -> void:
	playerRef.takeDamage(attack)

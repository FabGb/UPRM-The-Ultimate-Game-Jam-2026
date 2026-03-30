extends CharacterBody2D

var speed = 25.0
var health = 50
var attack = 10
var playerRef
var baseXDirection = -1
var baseYDirection = -1
var xDirectionTimer = 120
var yDirectionTimer = 20

var knockback = false
var knockbackTime = 0

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
	if health <= 0:
		queue_free()

	if knockbackTime > 0:
		knockbackTime -= 1
		$Sprite2D.modulate = Color(1, 0, 0)

	else:
		$Sprite2D.modulate = Color(1, 1, 1)
		if getDistance(playerRef.position) < 50:
			angle = atan2(playerRef.position.y - position.y, playerRef.position.x - position.x)
			velocity.x = speed * cos(angle)
			velocity.y = speed * sin(angle)
		else:
			velocity.x = speed * baseXDirection
			xDirectionTimer -= 1
			if xDirectionTimer <= 0:
				xDirectionTimer = 120
				baseXDirection *= -1

			velocity.y = 5 * baseYDirection
			yDirectionTimer -= 1
			if yDirectionTimer <= 0:
				yDirectionTimer = 20
				baseYDirection *= -1
			
			if knockback:
				velocity = Vector2(-sign(velocity.x) * speed * playerRef.force.x, -speed * playerRef.force.y)
				knockback = false
				knockbackTime = 10


	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())

func _on_killable_area_entered(area: Area2D) -> void:
	health -= playerRef.attack
	knockback = true


func _on_killable_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		playerRef.takeDamage(attack)

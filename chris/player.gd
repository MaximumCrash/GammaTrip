extends Area2D
signal hit
@export var speed = 400
var screen_size

# shoot
@export var bullet_speed = 400
@export var fire_rate_ms = 200
var last_fire_time = 0

@export var bullet_scene: PackedScene

func _ready():
	screen_size = get_viewport_rect().size

func start(player_speed, pos):
	speed = player_speed
	position = pos
	$CollisionShape2D.disabled = false

func _process(delta):
	# move
	var velocity = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1

	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if Input.is_action_pressed("move_down"):
		velocity.y += 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	# shoot
	if Input.is_action_pressed("fire"):
		var time = Time.get_ticks_msec()
		if time - last_fire_time > fire_rate_ms:
			last_fire_time = time

			var bullet = bullet_scene.instantiate()
			var root = get_tree().get_root()
			root.add_child(bullet)
			bullet.global_position = $BulletSpawn.global_position
			bullet.shoot(bullet_speed)


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)

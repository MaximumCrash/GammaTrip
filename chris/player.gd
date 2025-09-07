class_name Player
extends Area2D

signal hit
@export var speed := 400.0
var screen_size: Vector2

# shoot
@export var bullet_speed := 400.0
@export var fire_rate_ms := 200.0
@export var bullet_lifetime := 0.5
@export var num_bullets := 5
var last_fire_time := 0.0

@export var bullet_scene: PackedScene

var bullets: Array[Bullet] 
var bullet_index: int

func _ready() -> void:
	screen_size = get_viewport_rect().size

	bullet_index = 0

	# HACK doing this immediately fails
	var wait: float = 0.01
	await get_tree().create_timer(wait).timeout

	# spawn bullet pool
	var root:Node = get_tree().get_root()
	for i in range(0, num_bullets):
		var bullet:Bullet = bullet_scene.instantiate()
		root.add_child(bullet)
		bullet.set_state(false)
		bullets.push_back(bullet)

func start(player_speed: float, pos: Vector2) -> void:
	speed = player_speed
	position = pos
	$CollisionShape2D.disabled = false

func _process(delta: float) -> void:
	# move
	var velocity:Vector2 = Vector2.ZERO

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
		var time := Time.get_ticks_msec()
		if time - last_fire_time > fire_rate_ms:
			last_fire_time = time

			var bullet := bullets[bullet_index]
			if !bullet.is_shooting:
				var spawn_pos:Vector2 = $BulletSpawn.global_position
				bullet.shoot(spawn_pos, bullet_speed, bullet_lifetime)

			bullet_index += 1

			if bullet_index >= num_bullets:
				bullet_index = 0


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)

class_name Player
extends Area2D

signal hit
@export var speed := 400.0
var screen_size: Vector2

@export var weapons: Array[Weapon]

func _ready() -> void:
	screen_size = get_viewport_rect().size

	# HACK doing this immediately fails
	var wait: float = 0.01
	await get_tree().create_timer(wait).timeout

	for weapon in weapons:
		weapon.init()

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
		for weapon in weapons:
			weapon.attack()

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)

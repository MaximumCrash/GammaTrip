class_name Player
extends Area2D

signal death
@export var speed := Vector2(400.0, 200.0)
@export var charge := 10.0
var screen_size: Vector2

@export var weapon_slots: Array[Node2D]
var weapons: Array[Weapon]

func _ready() -> void:
	screen_size = get_viewport_rect().size

func start(pos: Vector2) -> void:
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
		$AnimatedSprite2D.animation = "move"
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()


	var dir := 0
	if velocity.x < 0:
		dir = -15
	elif velocity.x > 0:
		dir = 15
	else:
		dir = 0

	$AnimatedSprite2D.rotation_degrees = dir
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	# shoot
	if Input.is_action_pressed("fire"):
		for weapon in weapons:
			weapon.attack()

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	hide()
	death.emit()
	$CollisionShape2D.set_deferred("disabled", true)


func equip_weapon(weapon_scene: PackedScene, slot: int) -> void:
	var weapon : Weapon = weapon_scene.instantiate()
	weapon_slots[slot].add_child(weapon)
	weapons.push_back(weapon)
	weapon.init()

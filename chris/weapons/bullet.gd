class_name Bullet
extends Area2D

@export var damage := 1

var speed: float
var lifetime: float
var is_shooting: bool

func shoot(pos: Vector2, bullet_speed: float, bullet_lifetime: float) -> void:
	speed = bullet_speed
	lifetime = bullet_lifetime
	set_state(true)
	global_position = pos

func _physics_process(delta: float) -> void:
	if !is_shooting:
		return

	lifetime -= delta
	if lifetime <= 0:
		set_state(false)

	position -= transform.y * speed * delta

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	body.get_parent().damage(damage)
	set_state(false)

func set_state(shoot: bool) -> void:
	is_shooting = shoot

	if is_shooting:
		show()
	else:
		hide()

	$CollisionShape2D.set_deferred("disabled", !shoot)

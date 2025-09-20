class_name Player
extends Area2D

signal death
@export var speed := Vector2(400.0, 200.0)
@export var charge := 0.0
var charge_max := 10.0
var charge_fill_rate := 2.0
var charge_spend_rate := 2.5 # TODO: charge cost can vary with weapon

var screen_size: Vector2

@export var weapon_slots: Array[Node2D]
var weapons: Array[Weapon]
var special_weapons : Array[Weapon]

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

	var fired_special := false
	if Input.is_action_pressed("fire_special"):
		if charge > 0:
			fired_special = true
			for weapon in special_weapons:
				charge -= charge_spend_rate * delta
				weapon.attack()

	if !fired_special:
		charge += charge_fill_rate * delta
		charge = min(charge, charge_max)

	queue_redraw()

func _draw() -> void:
	const min_size := 0.0
	const max_size := 25.0
	const offset := Vector2(75, -75)
	var t := charge/charge_max

	var inner_size := lerpf(min_size, max_size, t)

	draw_circle(offset, inner_size, Color.KHAKI, true, -1.0, true)
	draw_circle(offset, max_size, Color.FOREST_GREEN, false, 2.0, true) # outer edge

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	hide()
	death.emit()
	$CollisionShape2D.set_deferred("disabled", true)


func equip_ship(ship_config: ShipConfig) -> void:
	var slot := 0

	if ship_config.primary_weapon != null:
		equip_weapon(ship_config.primary_weapon, slot, false)
		slot += 1

	if ship_config.secondary_weapon != null:
		equip_weapon(ship_config.secondary_weapon, slot, false)
		slot += 1

	if ship_config.special_weapon != null:
		equip_weapon(ship_config.special_weapon, slot, true)
		slot += 1


	speed  = ship_config.move_speed
	charge = ship_config.base_charge
	charge_max = charge


func equip_weapon(weapon_scene: PackedScene, slot: int, is_special: bool) -> void:
	var weapon : Weapon = weapon_scene.instantiate()
	weapon_slots[slot].add_child(weapon)

	var array := weapons
	if is_special:
		array = special_weapons

	array.push_back(weapon)
	weapon.init()

class_name Weapon
extends Node

@export var bullet_scene: PackedScene

# shoot
@export var bullet_speed := 400.0
@export var fire_rate_ms := 200.0
@export var bullet_lifetime := 0.5
@export var num_bullets := 5
var last_fire_time := 0.0

var bullets: Array[Bullet] 
var bullet_index: int

func init() -> void:
	bullet_index = 0

	var root:Node = get_tree().get_root()
	for i in range(0, num_bullets):
		var bullet:Bullet = bullet_scene.instantiate()
		root.add_child(bullet)
		bullet.set_state(false)
		bullets.push_back(bullet)
	

func attack() -> void:
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

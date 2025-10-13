class_name Weapon
extends Node2D

@export var bullet_scene: PackedScene

# shoot
@export var bullet_speed := 400.0
@export var fire_rate_ms := 200.0
@export var bullet_lifetime := 0.5
@export var num_bullets := 5
var last_fire_time := 0.0

var bullets: Array[Bullet] 
var bullet_index: int

enum Kind {
	MACHINE_GUN = 0,
	BEAM = 1,
	SWORD = 2,
}
@export var kind: Kind

@export var charge_time := 0.5
var charge_timer := 0.0

var is_attack := false

@export_group("Beam")
@export var beam_dps := 10.0
@export var beam_length := 1000
@export var beam_pulse_ms := 1000

var beam_last_fire := 0.0
var beam_hit := false
var beam_active := false
var beam_start := Vector2.ZERO
var beam_end := Vector2.ZERO

var state_machine: AnimationNodeStateMachinePlayback

func _ready() -> void:
	match kind:
		Kind.BEAM:
			$RayCast2D.target_position = Vector2.UP * beam_length

func init() -> void:
	match kind:
		Kind.MACHINE_GUN:
			bullet_index = 0

			var root:Node = get_tree().get_root()
			for i in range(0, num_bullets):
				var bullet:Bullet = bullet_scene.instantiate()
				root.add_child(bullet)
				bullet.set_state(false)
				bullets.push_back(bullet)

		Kind.SWORD:
			state_machine = $AnimationTree.get("parameters/playback")

func _process(delta: float) -> void:
	var time := Time.get_ticks_msec()

	match kind:
		Kind.MACHINE_GUN, Kind.SWORD:
			if !is_attack:
				return

		Kind.BEAM:
			if !is_attack:
				beam_active = false
				charge_timer = 0
				$AnimatedSprite2D.animation = "idle"
				$AnimatedSprite2D.play()
			else:
				charge_timer += delta

			if charge_timer <= charge_time:
				$AnimatedSprite2D.animation = "charge"
				$AnimatedSprite2D.play()
				is_attack = false
				beam_active = false
			else:
				if !beam_active:
					beam_last_fire = time
					beam_active = true

			queue_redraw()
			is_attack = false
			return

	is_attack = false

	if time - last_fire_time > fire_rate_ms:
		last_fire_time = time
		var spawn_pos: Vector2 = $BulletSpawn.global_position

		match kind:
			Kind.MACHINE_GUN:
				var bullet := bullets[bullet_index]
				if !bullet.is_shooting:
					bullet.shoot(spawn_pos, global_rotation, bullet_speed, bullet_lifetime)

				bullet_index += 1

				if bullet_index >= num_bullets:
					bullet_index = 0

			Kind.SWORD:
				$Bullet_Sword.shoot(spawn_pos, 0, bullet_speed, bullet_lifetime)
				state_machine.travel("attack")


func _physics_process(delta: float) -> void:
	if kind != Kind.BEAM:
		return

	if !beam_active:
		return

	beam_hit = $RayCast2D.is_colliding()
	if beam_hit:
		beam_start = $RayCast2D.global_position
		beam_end = $RayCast2D.get_collision_point()

		var body : Node2D = $RayCast2D.get_collider()
		if body != null:
			body.get_parent().damage(beam_dps * delta)


func _draw() -> void:
	if kind != Kind.BEAM:
		return

	if beam_active:
		var elapsed := Time.get_ticks_msec() - beam_last_fire
		elapsed = wrapf(elapsed, 0, beam_pulse_ms)
		var percent := elapsed/beam_pulse_ms
		var color : Color = lerp(Color.AQUA, Color.YELLOW, percent)

		var length := beam_length

		if beam_hit:
			length = beam_start.distance_to(beam_end)

		var p0 :Vector2 = Vector2.ZERO
		var p1 :Vector2 = p0 + Vector2.UP*length
		draw_line(p0, p1, color, 50)
	else:
		if charge_timer > 0.0:
			var percent := charge_timer / charge_time
			var color : Color = lerp(Color.GRAY, Color.GOLDENROD, percent)
			var dash := lerpf(10, 5, percent)
			var width := lerpf(1, 8, percent)
			var p0 :Vector2 = Vector2.ZERO
			var p1 :Vector2 = p0 + Vector2.UP*beam_length
			draw_dashed_line(p0, p1, color, width, dash)

func attack() -> void:
	is_attack = true

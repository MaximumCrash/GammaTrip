extends Node

@export var mob_scene: PackedScene
@export var player_speed: float = 500
@export var min_enemy_speed: float= 200
@export var max_enemy_speed: float = 400
var score: int

func _ready() -> void:
	$Player.hide()

func _on_hud_start_game() -> void:
	new_game()

func new_game() -> void:
	score = 0
	$StartTimer.start()
	$HUD.update_score(score)
	var wait: float = 0.75
	$HUD.show_message("Gamma", wait)
	await get_tree().create_timer(wait).timeout
	$HUD.show_message("Trip", wait)
	await get_tree().create_timer(wait).timeout

	$Player.show()
	$Player.start(player_speed, $StartPos.position)


func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()

func _on_mob_timer_timeout() -> void:
	var mob: Enemy = mob_scene.instantiate()

	var mob_spawn_location: Node = $MobPath/MobSpawn
	mob_spawn_location.progress_ratio = randf()
	
	mob.position = mob_spawn_location.position

	var dir: float = mob_spawn_location.rotation + PI / 2

	dir += randf_range(PI/2, -PI/2)
	mob.rotation = dir

	var vel: Vector2 = Vector2(randf_range(min_enemy_speed, max_enemy_speed), 0.0)
	mob.linear_velocity = vel.rotated(dir)

	add_child(mob)

func game_over() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()

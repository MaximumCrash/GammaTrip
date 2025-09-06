extends Node

@export var mob_scene: PackedScene
var score

func _on_hud_start_game() -> void:
	new_game()

func new_game():
	score = 0
	$Player.start($StartPos.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")


func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()

func _on_mob_timer_timeout() -> void:
	var mob = mob_scene.instantiate()

	var mob_spawn_location = $MobPath/MobSpawn
	mob_spawn_location.progress_ratio = randf()
	
	mob.position = mob_spawn_location.position

	var dir = mob_spawn_location.rotation + PI / 2

	dir += randf_range(-PI / 4, PI / 4)
	mob.rotation = dir

	var vel = Vector2(randf_range(25.0, 75.0), 0.0)
	mob.linear_velocity = vel.rotated(dir)

	add_child(mob)

func game_over() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()

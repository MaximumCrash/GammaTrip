extends Node

@export var mob_scene: PackedScene
@export var player_speed: float = 500
@export var min_enemy_speed: float= 200
@export var max_enemy_speed: float = 400
var score: int

@export var min_enemy_hp := 1
@export var max_enemy_hp := 5

var enemies: Array[Enemy]
var spawn_count: int
var wave: int

@export var enemies_per_wave := 10
var wave_kind: int

func _ready() -> void:
	wave = 1
	wave_kind = 0
	$Player.hide()

func _on_hud_start_game() -> void:
	new_game()

func new_game() -> void:
	score = 0
	$StartTimer.start()
	$HUD.update_score(score, wave)
	var wait: float = 0.75
	$HUD.show_message("Gamma", wait)
	await get_tree().create_timer(wait).timeout
	$HUD.show_message("Trip", wait)
	await get_tree().create_timer(wait).timeout

	$Player.show()
	$Player.start(player_speed, $StartPos.position)

func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()

func _on_mob_timer_timeout() -> void:
	var mob: Enemy = mob_scene.instantiate()
	mob.hp = randi_range(min_enemy_hp, max_enemy_hp)

	var mob_spawn_location:Node = $MobPath/MobSpawn
	mob_spawn_location.progress_ratio = randf()
	var spawn_pos:Vector2 = mob_spawn_location.position

	var path: Path2D
	match wave_kind:
		0:
			path = $Paths/Line
		1:
			path = $Paths/Curve
		2:
			path = $Paths/S_Curve
			
	mob.h_offset = path.position.x - spawn_pos.x

	path.add_child(mob)
	enemies.push_back(mob)

	mob.explode.connect(_on_mob_explode)
	spawn_count += 1


func _process(delta: float) -> void:
	for enemy in enemies:
		enemy.progress += delta * max_enemy_speed

func game_over() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()


func _on_mob_explode(enemy: Enemy, global_pos: Vector2) -> void:
	var idx := enemies.find(enemy)

	if idx == -1:
		return

	enemies.remove_at(idx)
	$EnemyExplode.global_position = global_pos
	$EnemyExplode.restart()

	score += 1

	# pick random move path
	if score % enemies_per_wave == 0:
		wave_kind = randi_range(0, 2)
		wave += 1

		var wait:float = $MobTimer.wait_time
		wait -= 0.1
		wait = max(0.2, wait)
		$MobTimer.wait_time = wait

	$HUD.update_score(score, wave)

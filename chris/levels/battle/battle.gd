class_name Battle
extends Node

signal player_score
signal player_death
signal battle_win

@export_group("Waves")
@export var wave_data : Array[WaveData]
var enemies_to_spawn := 0
var killed_this_wave := 0

@export_group("Player")
@export var player_speed: float = 500
var score: int

var enemies: Array[Enemy]
var spawn_count: int
var wave: int
var is_battle_over := false

enum Path {LINE, CURVE, S_CURVE}

func init(player: Player) -> void:
	wave = 0

	player.show()
	player.start(player_speed, $StartPos.position)
	player.death.connect(game_over)

	spawn_wave(wave)

func spawn_wave(wave_idx: int) -> void:
	var current_wave := wave_data[wave_idx]

	var path: Path2D
	match current_wave.path:
		Path.LINE:
			path = $Paths/Line
		Path.CURVE:
			path = $Paths/Curve
		Path.S_CURVE:
			path = $Paths/S_Curve

	for i in range(current_wave.num_enemies):
		var mob: Enemy = current_wave.enemy_scene.instantiate()

		var hp    := randi_range(current_wave.min_enemy_hp, current_wave.max_enemy_hp)
		var speed := randf_range(current_wave.min_enemy_speed, current_wave.max_enemy_speed) 

		mob.init(hp, speed)

		var mob_spawn_location:Node = $MobPath/MobSpawn
		mob_spawn_location.progress_ratio = randf()
		var spawn_pos:Vector2 = mob_spawn_location.position
			
		mob.h_offset = path.position.x - spawn_pos.x

		path.add_child(mob)
		enemies.push_back(mob)

		mob.explode.connect(_on_mob_explode)
		spawn_count += 1

	player_score.emit(0, wave+1)

func _process(delta: float) -> void:
	for enemy in enemies:
		enemy.progress += delta * enemy.move_speed

		if enemy.progress_ratio >= 1.0:
			enemy.path_completed()

func game_over() -> void:
	player_death.emit()
	is_battle_over = true

func _on_mob_explode(enemy: Enemy, global_pos: Vector2, killed_by_player: bool) -> void:
	if is_battle_over:
		return

	var idx := enemies.find(enemy)

	if idx == -1:
		return

	enemies.remove_at(idx)
	$EnemyExplode.global_position = global_pos
	$EnemyExplode.restart()
	killed_this_wave += 1

	var current_wave := wave_data[wave]
	var remaining_enemies := current_wave.num_enemies - killed_this_wave

	if remaining_enemies <= 0:
		killed_this_wave = 0
		wave += 1

		if wave >= wave_data.size():
			battle_win.emit()
			is_battle_over = true
			return
		else:
			spawn_wave(wave)

	# enemies are also destroyed by going off screen
	if killed_by_player:
		var enemy_score_value := 1
		score += enemy_score_value
		player_score.emit(enemy_score_value, wave+1)

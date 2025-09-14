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
@export var min_enemy_speed: float= 200
@export var max_enemy_speed: float = 400
var score: int

@export_group("Enemy")
@export var mob_scene: PackedScene
@export var min_enemy_hp := 1
@export var max_enemy_hp := 5

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

	$MobTimer.wait_time = wave_data[wave].enemy_spawn_rate
	$MobTimer.start()

func _on_mob_timer_timeout() -> void:
	var mob: Enemy = mob_scene.instantiate()
	mob.hp = randi_range(min_enemy_hp, max_enemy_hp)

	var mob_spawn_location:Node = $MobPath/MobSpawn
	mob_spawn_location.progress_ratio = randf()
	var spawn_pos:Vector2 = mob_spawn_location.position

	var current_wave := wave_data[wave]
	var path: Path2D

	match current_wave.path:
		Path.LINE:
			path = $Paths/Line
		Path.CURVE:
			path = $Paths/Curve
		Path.S_CURVE:
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
	$MobTimer.stop()
	player_death.emit()
	is_battle_over = true

func _on_mob_explode(enemy: Enemy, global_pos: Vector2) -> void:
	if is_battle_over:
		return

	var idx := enemies.find(enemy)

	if idx == -1:
		return

	enemies.remove_at(idx)
	$EnemyExplode.global_position = global_pos
	$EnemyExplode.restart()
	killed_this_wave += 1

	var enemy_score_value := 1
	score += enemy_score_value

	var current_wave := wave_data[wave]
	var remaining_enemies := current_wave.num_enemies - killed_this_wave

	if remaining_enemies <= 0:
		killed_this_wave = 0
		wave += 1

		if wave >= wave_data.size():
			battle_win.emit()
			is_battle_over = true
			return

		var wait:float = current_wave.enemy_spawn_rate
		wait -= 0.1
		wait = max(current_wave.min_enemy_spawn_rate, wait)
		$MobTimer.wait_time = wait

	player_score.emit(enemy_score_value, wave+1)

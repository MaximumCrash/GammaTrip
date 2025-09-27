class_name Battle
extends Node2D

signal player_score
signal player_death
signal battle_win

@export_group("Waves")
@export var config : BattleData
var last_enemy_spawn_idx := 0

@export_group("Enemy")
@export var enemy_types : Array[PackedScene] # runs parallel to Enemy enum
enum EnemyKind {BASIC}

@export_group("Player")
var score: int

@export_group("Path")
@export var path_types : Array[PackedScene] # parallel to Path enum
enum PathKind {LINE, QUADRATIC, CUBIC}


@export_group("Path Visualizer")
@export var path_color_0 : Color
@export var path_color_1 : Color
@export var path_draw_phase_seconds := 1.0
@export var path_length_seconds := 0.25

var battle_time := 0.0
var enemies: Array[Enemy]
var enemy_paths: Array[Path2D]
var enemy_lifetimes: Array[float]

var is_battle_over := false

func init(player: Player, battle_config : BattleData) -> void:
	player.show()
	player.start($StartPos.position)
	player.death.connect(game_over)

	config = battle_config

func process_spawning(time: float) -> void:
	if last_enemy_spawn_idx >= config.enemies.size():
		return

	var data := config.enemies[last_enemy_spawn_idx]
	if battle_time < data.spawn_time: # TODO: sort array by spawn time to be sure
		return

	var path_idx := data.path
	var enemy_idx := data.kind
	var mob: Enemy = enemy_types[enemy_idx].instantiate()

	mob.init(data.health, data.speed)

	var root := get_tree().get_root()
	var path := path_types[path_idx].instantiate()
	path.global_position = data.origin
	root.add_child(path)
	path.add_child(mob)

	enemies.push_back(mob)
	enemy_paths.push_back(path)
	enemy_lifetimes.push_back(0)

	mob.explode.connect(_on_mob_explode)
	last_enemy_spawn_idx += 1

	player_score.emit(0)

func _process(delta: float) -> void:
	process_spawning(battle_time)

	for i in range(enemies.size()):
		var enemy := enemies[i]

		var lifetime := enemy_lifetimes[i]
		if lifetime >= path_draw_phase_seconds:
			enemy.show()
			enemy.progress += delta * enemy.move_speed

			if enemy.progress_ratio >= 1.0:
				enemy.path_completed()
		else:
			enemy.hide()

		enemy_lifetimes[i] += delta

	queue_redraw()
	battle_time += delta

func _draw() -> void:
	for i in range(enemy_paths.size()):
		var path := enemy_paths[i]
		var curve := path.get_curve()

		var lifetime := enemy_lifetimes[i]
		var t := lifetime/path_draw_phase_seconds

		var p0 : Vector2 = curve.samplef(t-path_length_seconds)
		var p1 : Vector2 = curve.samplef(t)

		# apply path transform to the curve sample
		p0 = path.global_transform * p0
		p1 = path.global_transform * p1

		var color : Color = lerp(path_color_0, path_color_1, t)
		draw_line(p0, p1, color, 5.0)

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
	enemy_paths.remove_at(idx)
	enemy_lifetimes.remove_at(idx)

	$EnemyExplode.global_position = global_pos
	$EnemyExplode.restart()

	var alive := enemies.size()
	var all_spawned := last_enemy_spawn_idx == config.enemies.size()

	if alive == 0 && all_spawned:
		battle_win.emit()
		is_battle_over = true
		return

	# enemies are also destroyed by going off screen
	if killed_by_player:
		var enemy_score_value := 1
		score += enemy_score_value
		player_score.emit(enemy_score_value)

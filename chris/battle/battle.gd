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
enum EnemyKind {
	BASIC = 0, 
	SNAKE = 1,
}

@export_group("Player")
var score: int

@export_group("Path")
@export var path_types : Array[PackedScene] # parallel to Path enum
enum PathKind {
	LINE_V = 0,
	LINE_H = 1,
	QUADRATIC = 2,
	CUBIC = 3,
}

enum PathDirection {
	FORWARD = 0,
	BACKWARD = 1,
}

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
	if time < data.spawn_time: # TODO: sort array by spawn time to be sure
		return

	var enemy := spawn_enemy(data)
	last_enemy_spawn_idx += 1

	# snake spawns basic followers
	if enemy.kind == EnemyKind.SNAKE:
		for i in range(0, 9):
			# keep snake's params
			var e := spawn(EnemyKind.BASIC, data.path, data.path_dir, data.health, data.origin, data.speed)

			# but spawn with a delay
			var delay_per := 0.2
			var delay := delay_per * (i+1)
			e.move_delay = delay

	player_score.emit(0)

func spawn_enemy(data: EnemyData) -> Enemy:
	return spawn(data.kind, data.path, data.path_dir, data.health, data.origin, data.speed)

func spawn(enemy: EnemyKind, path: PathKind, path_dir: PathDirection, health: int, origin: Vector2, speed: float) -> Enemy:
	var enemy_inst: Enemy = enemy_types[enemy].instantiate()

	var root := get_tree().get_root()
	var path_inst := path_types[path].instantiate()
	path_inst.global_position = origin
	root.add_child(path_inst)
	path_inst.add_child(enemy_inst)

	enemies.push_back(enemy_inst)
	enemy_paths.push_back(path_inst)
	enemy_lifetimes.push_back(0)

	enemy_inst.init(health, speed, enemy, path_dir)
	enemy_inst.explode.connect(_on_enemy_explode)

	return enemy_inst

func _process(delta: float) -> void:
	process_spawning(battle_time)

	for i in range(enemies.size()):
		var enemy := enemies[i]

		var lifetime := enemy_lifetimes[i]
		if lifetime >= path_draw_phase_seconds:
			enemy.show()
			enemy.process_move(delta)

			if enemy.reached_path_end():
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
		var look_back := path_length_seconds

		# flip path draw direction
		if enemies[i].path_dir == PathDirection.BACKWARD:
			t = 1.0 - (lifetime/path_draw_phase_seconds)
			look_back = -path_length_seconds

		var p0 : Vector2 = curve.samplef(t-look_back)
		var p1 : Vector2 = curve.samplef(t)

		# apply path transform to the curve sample
		p0 = path.global_transform * p0
		p1 = path.global_transform * p1

		var color : Color = lerp(path_color_0, path_color_1, t)
		draw_line(p0, p1, color, 5.0)

func game_over() -> void:
	player_death.emit()
	is_battle_over = true

func _on_enemy_explode(enemy: Enemy, global_pos: Vector2, killed_by_player: bool) -> void:
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

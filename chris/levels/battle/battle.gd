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
var score: int

@export_group("Path")
@export var path_scenes : Array[PackedScene]
@export var path_origins : Array[Node2D]

var enemies: Array[Enemy]
var spawn_count: int
var wave: int
var is_battle_over := false

enum Path {LINE, QUADRATIC, CUBIC}
enum PathOrigin {TOP, RIGHT, BOTTOM, LEFT}

func init(player: Player) -> void:
	wave = 0

	player.show()
	player.start($StartPos.position)
	player.death.connect(game_over)

	spawn_wave(wave)

func spawn_wave(wave_idx: int) -> void:
	var current_wave := wave_data[wave_idx]

	var path_idx := current_wave.path
	var root := get_tree().get_root()

	var path_rotation := 0.0
	var path_origin := path_origins[current_wave.path_origin]
	match current_wave.path_origin:
		PathOrigin.TOP:
			path_rotation = 0
		PathOrigin.RIGHT:
			path_rotation = 90.0
		PathOrigin.BOTTOM:
			path_rotation = 180.0
		PathOrigin.LEFT:
			path_rotation = 270.0

	var mob_spawn_location:Node = path_origin.get_node("Spawn")

	for i in range(current_wave.num_enemies):
		var mob: Enemy = current_wave.enemy_scene.instantiate()

		var hp    := randi_range(current_wave.min_enemy_hp, current_wave.max_enemy_hp)
		var speed := randf_range(current_wave.min_enemy_speed, current_wave.max_enemy_speed) 

		mob.init(hp, speed)

		mob_spawn_location.progress_ratio = randf()
		var spawn_pos:Vector2 = mob_spawn_location.global_position
			
		var path : Path2D = path_scenes[path_idx].instantiate()
		var curve := Curve2D.new()
		var screen_size: Vector2 = get_viewport().size
		for point in path.curve.get_baked_points():
			var norm_point := point.normalized()
			var p := Vector2.ZERO
			p.x = norm_point.x * screen_size.x
			p.y = norm_point.y * screen_size.y
			curve.add_point(p)

		path.set_curve(curve)
		path.rotation_degrees = path_rotation

		path.global_position = spawn_pos
		root.add_child(path)
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

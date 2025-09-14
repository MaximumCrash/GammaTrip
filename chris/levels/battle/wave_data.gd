class_name WaveData
extends Resource

@export var num_enemies := 1
@export var enemy_scene : PackedScene
@export var enemy_spawn_rate := 1.0

@export_group("Health")
@export var min_enemy_hp := 1
@export var max_enemy_hp := 5

@export_group("Movement")
@export var path : Battle.Path
@export var min_enemy_speed := 200.0
@export var max_enemy_speed := 400.0

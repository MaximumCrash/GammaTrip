class_name EnemyData
extends Resource

@export var kind: Battle.EnemyKind
@export var spawn_time := 0.0
@export var health := 1
@export var origin: Vector2
@export var path: Battle.PathKind
@export var path_dir := Battle.PathDirection.FORWARD
@export var speed := 100.0

class_name Enemy
extends Node2D

signal explode

var killed_by_player := true

@export_group("Movement")
@export var path_follow: PathFollow2D
@export var body: AnimatableBody2D
@export var anim: AnimatedSprite2D

@export var move_speed := 400.0
var path_dir : Battle.PathDirection

@export_group("Health")
@export var hp := 1.0

func init(health: float, speed: float, direction: Battle.PathDirection) -> void:
	hp = health
	move_speed = speed
	path_dir = direction

func get_path_multi() -> float:
	if path_dir == Battle.PathDirection.FORWARD:
		return 1.0
	else:
		return -1.0

func process_move(delta: float) -> void:
	self.progress += delta * move_speed * get_path_multi()

func reached_path_end() -> bool:
	if path_dir == Battle.PathDirection.FORWARD:
		return self.progress_ratio >= 1
	else:
		return self.progress_ratio <= 0

func _ready() -> void:
	var mob_types: Array = Array(anim.sprite_frames.get_animation_names())
	anim.animation = mob_types.pick_random()
	anim.play()

func path_completed() -> void:
	killed_by_player = false
	queue_free()

func _exit_tree() -> void:
	explode.emit(self, global_position, killed_by_player)

func damage(amount: float) -> void:
	hp -= amount

	if hp <= 0:
		killed_by_player = true
		queue_free()

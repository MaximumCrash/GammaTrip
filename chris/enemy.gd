class_name Enemy
extends Node2D

signal explode

var killed_by_player := true

@export_group("Movement")
@export var path_follow: PathFollow2D
@export var body: AnimatableBody2D
@export var anim: AnimatedSprite2D

@export var move_speed := 400.0

@export_group("Health")
@export var hp := 1

func init(health: int, speed: float) -> void:
	hp = health
	move_speed = speed

func _ready() -> void:
	var mob_types: Array = Array(anim.sprite_frames.get_animation_names())
	anim.animation = mob_types.pick_random()
	anim.play()

func path_completed() -> void:
	killed_by_player = false
	queue_free()

func _exit_tree() -> void:
	explode.emit(self, global_position, killed_by_player)

func damage(amount: int) -> void:
	hp -= amount

	if hp <= 0:
		killed_by_player = true
		queue_free()

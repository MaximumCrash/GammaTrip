class_name Enemy
extends RigidBody2D

signal explode

var killed_by_player := true

func _ready() -> void:
	var mob_types: Array = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	killed_by_player = false
	queue_free()

func _exit_tree() -> void:
	if killed_by_player:
		explode.emit(global_position)

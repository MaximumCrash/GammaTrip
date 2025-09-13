extends Node2D

@export var weapon_to_equip : PackedScene

func _ready() -> void:
	await get_tree().create_timer(0.01).timeout

	$Player.equip_weapon(weapon_to_equip, 0)
	$Player.equip_weapon(weapon_to_equip, 1)
	$Player.equip_weapon(weapon_to_equip, 2)

class_name ShipConfig
extends Resource

@export var primary_weapon : PackedScene
@export var secondary_weapon : PackedScene
@export var special_weapon : PackedScene

@export var base_charge := 10.0
@export var move_speed := Vector2(400.0, 400.0)


@export var display_name := "My Cool Ship"
@export_multiline var display_description := "This ship is very cool!"

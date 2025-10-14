class_name UpgradeData
extends Resource

@export_group("Info")
@export var cost := 0
@export var display_name := "Title"
@export_multiline var display_description := "Description"

@export_group("Stats")
@export var move_speed := Vector2(0.0, 0.0)
@export var charge_fill_rate := 0.0
@export var charge_spend_rate := 0.0
@export var max_health := 0
@export var heal := 0

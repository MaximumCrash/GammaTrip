extends Node2D

enum State {START_MENU, PICK_WEAPON, BATTLE}
var state := State.START_MENU

@export var scene_battle     : PackedScene
@export var scene_add_weapon : PackedScene

@export var start_button : Button
@export var player : Player

var active_scene : Node

func _ready() -> void:
	start_button.pressed.connect(new_game)
	player.hide()

func new_game() -> void:
	start_button.hide()

	$StartTimer.start()
	var wait: float = 0.75
	$HUD.show_message("Gamma", wait)
	await get_tree().create_timer(wait).timeout
	$HUD.show_message("Trip", wait)
	await get_tree().create_timer(wait).timeout

	var weapon_scene := load_scene(State.PICK_WEAPON)
	weapon_scene.confirm_weapon_and_slot.connect(on_weapon_chosen)

func on_weapon_chosen(weapon_scene: PackedScene, slot: int) -> void:
	player.equip_weapon(weapon_scene, slot)
	var battle_scene := load_scene(State.BATTLE)
	battle_scene.init(player)

func load_scene(new_state: State) -> Node:
	state = new_state

	if active_scene != null:
		active_scene.queue_free()
		active_scene = null

	var scene : Node
	match state:
		State.PICK_WEAPON:
			scene = scene_add_weapon.instantiate()
		State.BATTLE:
			scene = scene_battle.instantiate()

	$ActiveSceneRoot.add_child(scene)
	active_scene = scene

	return scene
	

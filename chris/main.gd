extends Node2D

enum State {START_MENU, PICK_WEAPON, BATTLE}
var state := State.START_MENU

@export var scene_battle     : PackedScene
@export var scene_add_weapon : PackedScene

@export var start_button : Button
@export var player : Player

var active_scene : Node
var total_score := 0

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

	load_add_weapon()

# battle signals
func on_player_score(score: int, wave: int) -> void:
	total_score += score
	$HUD.update_score(total_score, wave)

func on_player_death() -> void:
	$HUD.show_game_over()
	load_scene(State.START_MENU)

func on_battle_win() -> void:
	load_add_weapon()

# add_weapon signals
func on_weapon_chosen(weapon_scene: PackedScene, slot: int) -> void:
	player.equip_weapon(weapon_scene, slot)
	load_battle()


func load_add_weapon() -> void:
	var weapon_scene := load_scene(State.PICK_WEAPON)
	weapon_scene.confirm_weapon_and_slot.connect(on_weapon_chosen)

func load_battle() -> void:
	var battle_scene := load_scene(State.BATTLE)
	battle_scene.init(player)

	battle_scene.player_score.connect(on_player_score)
	battle_scene.player_death.connect(on_player_death)
	battle_scene.battle_win.connect(on_battle_win)
	

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
	

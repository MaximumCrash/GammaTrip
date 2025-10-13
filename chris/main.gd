extends Node2D

enum State {
	START_MENU = 0,
	PICK_SHIP = 1,
	PICK_WEAPON = 2,
	BATTLE = 3,
}

var state := State.START_MENU

@export var scene_pick_ship  : PackedScene
@export var scene_pick_weapon : PackedScene
@export var scene_battle     : PackedScene

@export var start_button : Button
@export var player : Player

var active_scene : Node
var total_score := 0

@export_group("Battle")
@export var battles : Array[BattleData]
var battle_idx := 0

func _ready() -> void:
	start_button.pressed.connect(new_game)
	player.hide()

	start_button.grab_focus() # select button for controller

func new_game() -> void:
	start_button.hide()

	$StartTimer.start()
	var wait: float = 0.75
	$HUD.show_message("Gamma", wait)
	await get_tree().create_timer(wait).timeout
	$HUD.show_message("Trip", wait)
	await get_tree().create_timer(wait).timeout

	load_pick_ship()

# battle signals
func on_player_score(score: int) -> void:
	total_score += score
	$HUD.update_score(total_score)

func on_player_death() -> void:
	$HUD.show_game_over()
	load_scene(State.START_MENU)

func on_battle_win() -> void:
	load_pick_weapon()


func load_pick_ship() -> void:
	var scene := load_scene(State.PICK_SHIP)
	scene.confirm_ship.connect(on_ship_chosen)

func load_pick_weapon() -> void:
	var weapon_scene := load_scene(State.PICK_WEAPON)
	weapon_scene.confirm_weapon_and_slot.connect(on_weapon_chosen)

func load_battle() -> void:
	var battle_scene := load_scene(State.BATTLE)

	battle_scene.init(player, battles[battle_idx])

	# just loop for now
	battle_idx += 1
	if battle_idx >= battles.size():
		battle_idx = 0

	battle_scene.player_score.connect(on_player_score)
	battle_scene.player_death.connect(on_player_death)
	battle_scene.battle_win.connect(on_battle_win)


# scene signals
func on_weapon_chosen(weapon_scene: PackedScene, slot: int) -> void:
	player.equip_weapon(weapon_scene, slot, false)
	load_battle()

func on_ship_chosen(ship_config: ShipConfig) -> void:
	player.equip_ship(ship_config)
	load_battle()

func load_scene(new_state: State) -> Node:
	state = new_state

	if active_scene != null:
		active_scene.queue_free()
		active_scene = null

	var scene : Node
	match state:
		State.PICK_SHIP:
			scene = scene_pick_ship.instantiate()
		State.PICK_WEAPON:
			scene = scene_pick_weapon.instantiate()
		State.BATTLE:
			scene = scene_battle.instantiate()

	$ActiveSceneRoot.add_child(scene)
	active_scene = scene

	return scene
	

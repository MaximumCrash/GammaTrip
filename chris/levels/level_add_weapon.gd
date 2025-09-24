extends Control

signal confirm_weapon_and_slot

@export var weapon_scenes : Array[PackedScene]
var weapons : Array[Weapon]

var weapon_buttons : Array[Button]
var slot_buttons : Array[Button]

func _ready() -> void:
	for i in range(weapon_scenes.size()):
		weapons.push_back(weapon_scenes[i].instantiate())

	var w_buttons := $Weapon/WeaponPicker.get_children()
	var s_buttons := $Slot/SlotPicker.get_children()

	for i in range(w_buttons.size()):
		if i >= weapons.size():
			w_buttons[i].hide()
			continue

		w_buttons[i].show()
		w_buttons[i].text = str(Weapon.Kind.keys()[weapons[i].kind])
		weapon_buttons.push_back(w_buttons[i])

	for i in range(s_buttons.size()):
		slot_buttons.push_back(s_buttons[i])


	$ConfirmButton.pressed.connect(on_confirm)

	weapon_buttons[0].grab_focus()

func on_confirm() -> void:
	var weapon_idx  := -1
	var chosen_slot := -1

	for i in range(weapon_buttons.size()):
		if weapon_buttons[i].button_pressed:
			weapon_idx = i
			break

	for i in range(slot_buttons.size()):
		if slot_buttons[i].button_pressed:
			chosen_slot = i
			break

	if weapon_idx == -1 || chosen_slot == -1:
		return

	print("chose weapon: ", str(weapons[weapon_idx]), " in slot: ", chosen_slot)
	confirm_weapon_and_slot.emit(weapon_scenes[weapon_idx], chosen_slot)

extends Control

signal confirm_ship

@export var ships : Array[ShipConfig]
var buttons : Array[Button]

func _ready() -> void:
	var s_buttons := $Ship/Picker.get_children()

	for i in range(s_buttons.size()):
		if i >= ships.size():
			s_buttons[i].hide()
			continue

		s_buttons[i].show()
		s_buttons[i].text = ships[i].display_name
		buttons.push_back(s_buttons[i])

	$ConfirmButton.pressed.connect(on_confirm)

func _process(delta: float) -> void:
	for i in range(buttons.size()):
		if buttons[i].button_pressed:
			$Ship/Description.text = ships[i].display_description
			return

func on_confirm() -> void:
	var idx := -1

	for i in range(buttons.size()):
		if buttons[i].button_pressed:
			idx = i
			break

	if idx == -1:
		return

	print("chose ship: ", ships[idx].display_name)
	confirm_ship.emit(ships[idx])

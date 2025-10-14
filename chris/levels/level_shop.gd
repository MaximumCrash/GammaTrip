extends Control

signal confirm_purchase
signal exit_shop

@export var inventory : Array[UpgradeData]
@export var shop_items : Array[ShopItem]
var active_items : Array[UpgradeData]

func _ready() -> void:
	for i in range(shop_items.size()):
		var upgr_data: UpgradeData = inventory.pick_random()
		active_items.push_back(upgr_data)
		shop_items[i].display(upgr_data.display_name, upgr_data.cost, upgr_data.display_description)
		shop_items[i].pressed.connect(on_button.bind(i))

	$Control/ExitButton.pressed.connect(on_exit)
	shop_items[0].grab_focus()

func on_button(idx: int) -> void:
	print("purchase: ", shop_items[idx])
	confirm_purchase.emit(active_items[idx])

func on_exit() -> void:
	exit_shop.emit()

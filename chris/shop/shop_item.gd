class_name ShopItem
extends Button

@onready var name_label: Label = $"NameLabel"
@onready var cost_label: Label = $"CostLabel"
@onready var desc_label: Label = $"DescriptionLabel"

func display(item_name: String, cost: int, desc: String) -> void:
	name_label.text = item_name
	cost_label.text = "$" + str(cost)
	desc_label.text = desc

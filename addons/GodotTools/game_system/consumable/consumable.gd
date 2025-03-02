class_name Consumable
extends Resource

@export var effects: Array[ConsumableEffect]

## Key to use in item sets
const CONSUMABLE_KEY: String = "consumable"
## Key to use to reference the consumable's Resource (e.g. res://...)
const CONSUMABLE_RESOURCE_KEY: String = "consumable_resource"

func consume(consumer: Node, item_provider: ItemProvider) -> void:
	for effect in effects:
		effect.apply(consumer)
	item_provider.use_item(1)

func get_text() -> String:
	var effect_texts: Array[String] = []
	for effect in effects:
		effect_texts.append(effect.get_text())
	return "\n".join(effect_texts)

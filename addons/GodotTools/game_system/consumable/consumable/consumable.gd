class_name Consumable
extends Resource

@export var effects: Array[ConsumableEffect]

## Key to use in item sets
const CONSUMABLE_KEY: String = "consumable"
## Key to use to reference the consumable's Resource (e.g. res://...)
const CONSUMABLE_RESOURCE_KEY: String = "consumable_resource"

func consume(consumer_root: Node, item_provider: ItemProvider) -> void:
	var consumer: Consumer
	var consumers: Array[Consumer] = []
	consumers.assign(consumer_root.find_children("", "Consumer"))
	if consumers.size() == 0:
		consumer = ImmediateConsumer.new()
	else:
		consumer = consumers[0]
	
	if consumer.item_consumed_immediately:
		item_provider.use_item(1)

	consumer.start_consumption(
		self,
		# We have to use a lambda to keep this consumable around
		func():
			_consume.bind(consumer_root, consumer, item_provider).call())
	
func _consume(consumer_root: Node, consumer: Consumer, item_provider: ItemProvider):
	if not consumer.item_consumed_immediately:
		var used: int = item_provider.use_item(1)

		if used == 0:
			return

	for effect in effects:
		effect.apply(consumer_root)

func get_text() -> String:
	var effect_texts: Array[String] = []
	for effect in effects:
		effect_texts.append(effect.get_text())
	return "\n".join(effect_texts)

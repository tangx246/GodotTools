class_name GlootUnlockInteractable
extends UnlockInteractable

@export var key_id: String

var item_provider: GlootItemIdProvider

func _ready() -> void:
	super()
	item_provider = GlootItemIdProvider.new(null, key_id)
	add_child(item_provider)

func _on_interacted(interactor: Node) -> void:
	item_provider.root = (interactor as Interactor).actor
	if item_provider.has_item():
		var used: int = item_provider.use_item(1)
		if used != 1:
			push_error("Unable to use %s on %s" % [key_id, interactor])
			item_provider.root = null
			return
		super._on_interacted(interactor)
	else:
		print("%s has no key %s" % [item_provider.root, key_id])

	item_provider.root = null

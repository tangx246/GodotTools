@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("UtilitySelectorComposite", "Composite", preload("nodes/composites/utility_selector.gd"), preload("icon.svg"))
	add_custom_type("UtilityDecorator", "Decorator", preload("nodes/decorator/utility/utility_decorator.gd"), preload("icon.svg"))

func _exit_tree():
	remove_custom_type("UtilitySelectorComposite")
	remove_custom_type("UtilityDecorator")

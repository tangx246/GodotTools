@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("AnimationTicker", "Timer", preload("animation_ticker.gd"), preload("icon.svg"))

func _exit_tree():
	remove_custom_type("AnimationTicker")

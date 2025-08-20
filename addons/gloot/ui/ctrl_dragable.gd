@tool
extends Control

const CtrlDragable = preload("res://addons/gloot/ui/ctrl_dragable.gd")
const CtrlDropZone = preload("res://addons/gloot/ui/ctrl_drop_zone.gd")

# Somewhat hacky way to do static signals:
# https://stackoverflow.com/questions/77026156/how-to-write-a-static-event-emitter-in-gdscript/77026952#77026952

static var dragable_grabbed: Signal = (func():
	if (CtrlDragable as Object).has_user_signal("dragable_grabbed"):
		return (CtrlDragable as Object).dragable_grabbed
	(CtrlDragable as Object).add_user_signal("dragable_grabbed")
	return Signal(CtrlDragable, "dragable_grabbed")
).call()

static var dragable_dropped: Signal = (func():
	if (CtrlDragable as Object).has_user_signal("dragable_dropped"):
		return (CtrlDragable as Object).dragable_dropped
	(CtrlDragable as Object).add_user_signal("dragable_dropped")
	return Signal(CtrlDragable, "dragable_dropped")
).call()

signal grabbed(position)
signal dropped(zone, position)

static var _grabbed_dragable: CtrlDragable = null
static var _grab_offset: Vector2

var _enabled: bool = true


static func get_grabbed_dragable() -> CtrlDragable:
	if !is_instance_valid(_grabbed_dragable):
		return null
	return _grabbed_dragable


static func get_grab_offset() -> Vector2:
	return _grab_offset


static func get_grab_offset_local_to(control: Control) -> Vector2:
	return CtrlDragable.get_grab_offset() / control.get_global_transform().get_scale()

var sub_preview: Control
func _get_drag_data(_at_position: Vector2):
	if !_enabled:
		return null

	# Set on a separate canvas for multi-window support
	var canvas = CanvasLayer.new()
	canvas.layer = 2000
	get_tree().current_scene.add_child(canvas)
	var preview = Control.new()
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sub_preview = create_preview()
	sub_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.add_child(sub_preview)
	set_drag_preview(preview)
	preview.reparent(canvas)
	var offset: Vector2 = (sub_preview.size / 2) * get_global_transform().get_scale()
	sub_preview.global_position = get_tree().current_scene.get_viewport().get_mouse_position() - offset
	preview.tree_exited.connect(canvas.queue_free)

	_grabbed_dragable = self
	_grab_offset = offset
	dragable_grabbed.emit(_grabbed_dragable, _grab_offset)
	grabbed.emit(_grab_offset)

	return self


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		_grabbed_dragable = null


func create_preview() -> Control:
	return null


func activate() -> void:
	_enabled = true


func deactivate() -> void:
	_enabled = false


func is_active() -> bool:
	return _enabled


func is_dragged() -> bool:
	return _grabbed_dragable == self

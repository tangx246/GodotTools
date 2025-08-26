class_name AnimatedConsumer
extends Consumer

@export var root: Node
@export var object_spawn_location: Node
@export var consume_node_name: StringName = "Consume"
@export var unequip_node_name: StringName = "Unequip"
@export var time_scale_path: StringName = "parameters/Consume/TimeScale/scale"
@export var non_animated_consumer: Consumer = ImmediateConsumer.new()
@onready var tree: AnimationTree = root.find_children("", "AnimationTree")[0]

signal consume_finished
signal consume_started
var consuming: bool = false

func _ready() -> void:
	var sm = tree.tree_root.duplicate(true) as AnimationNodeStateMachine
	tree.tree_root = sm
	
	Signals.safe_connect(self, consume_finished, func(): consuming = false)
	Signals.safe_connect(self, consume_started, func(): consuming = true)

	Signals.safe_connect(self, tree.animation_finished, _on_anim_finished)
	Signals.safe_connect(self, tree.animation_started, _on_anim_started)
	
func _on_anim_finished(anim_name: StringName) -> void:
	if anim_name == tree.tree_root.get_node(consume_node_name).get_node("Animation").animation:
		consume_finished.emit()

func _on_anim_started(anim_name: StringName) -> void:
	if anim_name == tree.tree_root.get_node(consume_node_name).get_node("Animation").animation:
		consume_started.emit()

var current_finished: Callable
func start_consumption(consumable: Consumable, finished: Callable) -> void:
	if consumable is AnimatedConsumable:
		_start_animated_consumption(consumable, finished)
	else:
		non_animated_consumer.start_consumption(consumable, finished)

var spawned_object: Node
func _start_animated_consumption(consumable: AnimatedConsumable, finished: Callable) -> void:
	Signals.safe_connect(self, consume_started, func():
		_clear_spawned_object()
		_set_spawn_children_visibility(false)
		if consumable.animated_scene and object_spawn_location:
			spawned_object = consumable.animated_scene.instantiate()
			object_spawn_location.add_child(spawned_object)
	, CONNECT_ONE_SHOT)
	
	current_finished = finished
	var sm = tree.tree_root as AnimationNodeStateMachine
	tree.set(time_scale_path, consumable.time_scale)
	var smp = tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
	var consume_node = sm.get_node(consume_node_name)
	var consume_animation = consume_node.get_node("Animation")
	consume_animation.animation = consumable.consume_animation
	smp.travel(consume_node_name)
	Signals.safe_connect(self, consume_finished, _call_finished, CONNECT_ONE_SHOT)

func _clear_spawned_object():
	if is_instance_valid(spawned_object):
		spawned_object.queue_free()
		spawned_object = null

func _set_spawn_children_visibility(show: bool):
	for child in object_spawn_location.get_children():
		child.visible = show

func _call_finished() -> void:
	current_finished.call()
	current_finished = Callable()
	
	_clear_spawned_object()
	_set_spawn_children_visibility(true)

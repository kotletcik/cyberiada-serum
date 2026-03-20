extends Control

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var credits_button: Button = $VBoxContainer/CreditsButton
@onready var controls_button: Button = $VBoxContainer/ControlsButton
@onready var exit_button: Button = $VBoxContainer/ExitButton
@onready var credits_panel: Panel = $CreditsPanel
@onready var close_button: Button = $CreditsPanel/VBox/CloseButton
@onready var credits_scroll: ScrollContainer = $CreditsPanel/VBox/ScrollContainer
@onready var controls_panel: Panel = $ControlsPanel
@onready var controls_close_button: Button = $ControlsPanel/Close
@onready var black_transition: ColorRect = $BlackTransition

# @export var game_scene: PackedScene;

var _credits_tween = null

# var transitioned: bool = false;
var transition_started: bool = false;
@export var transition_speed: float = 1.0;

func _ready():
	start_button.pressed.connect(_on_start_pressed);
	credits_button.connect("pressed", Callable(self, "_on_credits_pressed"))
	controls_button.connect("pressed", Callable(self, "_on_controls_pressed"))
	exit_button.connect("pressed", Callable(self, "_on_exit_pressed"))
	close_button.connect("pressed", Callable(self, "_on_close_credits"))
	controls_close_button.connect("pressed", Callable(self, "_on_close_controls"))
	# transitioned = false;
	transition_started = false;
	remove_child(black_transition);

func _on_start_pressed():
	add_child(black_transition);
	black_transition.color.a = 0;
	transition_started = true;

func _process(delta: float) -> void:
	if(transition_started):
		black_transition.color.a += (1/transition_speed) * delta;
		if(black_transition.color.a > 1):
			request_ready();
			print(get_tree().change_scene_to_file("res://scenes/test_scenes/PJ_build_1_scene.tscn"));
		

func _on_controls_pressed():
	controls_panel.visible = true;

func _on_close_controls():
	controls_panel.visible = false;

func _on_credits_pressed():
	credits_panel.visible = true
	credits_scroll.scroll_vertical = 0
	if _credits_tween != null:
		_credits_tween.kill()
		_credits_tween = null
	var bar = null
	if credits_scroll.has_method("get_v_scrollbar"):
		bar = credits_scroll.get_v_scrollbar()
	# fallback: try to find a VScrollBar child by common names
	if bar == null:
		for child in credits_scroll.get_children():
			if child is ScrollBar:
				bar = child
				break
	# If we found a scrollbar, animate scroll_vertical. Otherwise animate CreditsVBox position as fallback.
	if bar != null:
		var target = bar.max_value
		var duration = max(8.0, float(target) / 40.0)
		_credits_tween = create_tween()
		_credits_tween.tween_property(credits_scroll, "scroll_vertical", target, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	else:
		var credits_label = $CreditsPanel/VBox/ScrollContainer/CreditsVBox/CreditsLabel
		var label_h = credits_label.get_minimum_size().y
		var view_h = credits_scroll.get_size().y
		# compute scroll target (content height - view height)
		var target = int(max(0, label_h - view_h))
		var duration = max(8.0, float(label_h + view_h) / 40.0)
		_credits_tween = create_tween()
		_credits_tween.tween_property(credits_scroll, "scroll_vertical", target, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _on_close_credits():
	if _credits_tween != null:
		_credits_tween.kill()
		_credits_tween = null
	credits_scroll.scroll_vertical = 0
	credits_panel.visible = false

func _on_exit_pressed():
	get_tree().quit()

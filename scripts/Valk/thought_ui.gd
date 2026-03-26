class_name ThoughtUI
extends Control

var thought_clue: Clue;
var is_on_thought_path: bool = false;
var is_reversed: bool = false;

var titleLabel: RichTextLabel;
var descLabel: RichTextLabel;

func _ready() -> void:
	titleLabel = get_node("TitleText");
	descLabel = get_node("DescText");

func set_thought_ui_instance(title: String, desc: String, x_pos: int, y_pos: int, clue: Clue, is_on_path: bool):
	titleLabel.text = title;
	descLabel.text = desc;
	position.x = x_pos;
	position.y = y_pos;
	if(x_pos == 0 && y_pos == 0):
		position = clue.ui_pos;
	thought_clue = clue;
	is_on_thought_path = is_on_path;

func set_is_reverse(value: bool) -> void:
	is_reversed = value;
	if(is_reversed):
		var style: StyleBox = get_theme_stylebox("panel").duplicate();
		style.set_bg_color(Color(0.8, 0.8, 0.8));
		add_theme_stylebox_override("panel", style);

		get_node("DescText").add_theme_color_override("default_color", Color.BLACK);
		get_node("TitleText").add_theme_color_override("default_color", Color.BLACK);
		# print(get_node("DescText").get_theme_color("font_color"));
		# get_node("DescText").add_theme_color_override("font_color", Color.BLACK);
		# print(get_node("DescText").get_theme_color("font_color"));
	else:
		var style: StyleBox = get_theme_stylebox("panel").duplicate();
		style.set_bg_color(Color.BLACK);
		add_theme_stylebox_override("panel", style);

		get_node("DescText").add_theme_color_override("default_color", Color.WHITE);
		get_node("TitleText").add_theme_color_override("default_color", Color.WHITE);

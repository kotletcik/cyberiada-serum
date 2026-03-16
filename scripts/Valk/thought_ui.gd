class_name ThoughtUI
extends Control

var thought_clue: Clue;
var is_on_thought_path: bool = false;

func set_thought_ui_instance(title: String, desc: String, x_pos: int, y_pos: int, clue: Clue, is_on_path: bool):
	get_node("TitleText").text = title;
	get_node("DescText").text = desc;
	position.x = x_pos;
	position.y = y_pos;
	if(x_pos == 0 && y_pos == 0):
		position = clue.ui_pos;
	thought_clue = clue;
	is_on_thought_path = is_on_path;

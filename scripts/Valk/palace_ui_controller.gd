extends Control

@export var thought_ui_scene: Resource;

var dragged_clue: Clue = null;
var dragged_thought: ThoughtUI = null;

var last_line_pos: Vector2 = Vector2(0,0);

func _draw() -> void:
	for i in range(0, UIManager.instance.thought_uis_count):
		if(!UIManager.instance.instanciated_thought_uis[i].is_on_thought_path): continue;
		if(last_line_pos == Vector2(0,0)): 
			last_line_pos = UIManager.instance.instanciated_thought_uis[i].position + UIManager.instance.instanciated_thought_uis[i].size/2;
			continue;
		var current_line_pos = UIManager.instance.instanciated_thought_uis[i].position + UIManager.instance.instanciated_thought_uis[i].size/2;
		draw_line(last_line_pos, current_line_pos, Color.WHITE, 2.0, true);
		last_line_pos = current_line_pos;	
	last_line_pos = Vector2(0,0);

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true;

func _get_drag_data(at_position: Vector2) -> Variant:
	dragged_thought = UIManager.instance.get_thought_ui_at(at_position);
	if(dragged_thought == null): return;
	if(dragged_thought.is_on_thought_path): return;
	dragged_clue = dragged_thought.thought_clue;

	var preview: ThoughtUI = thought_ui_scene.instantiate();
	dragged_thought.visible = false;
	preview.get_node("TitleText").text = dragged_thought.get_node("TitleText").text;
	preview.get_node("DescText").text = dragged_thought.get_node("DescText").text;
	preview.set_is_reverse(true);

	var c: Control = Control.new();
	c.add_child(preview);
	# preview.position = -0.5 * preview.size; # default to center of thought ui
	preview.position = -(at_position - dragged_thought.position);

	set_drag_preview(c);
	return dragged_clue;

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var data_clue : Clue = data as Clue;
	print(data_clue.name);
	dragged_thought.visible = true;
	var checked_clue: Clue = UIManager.instance.get_clue_at(at_position);
	if(checked_clue == null): return;
	if(PalaceManager.instance.is_correct_thought(checked_clue, dragged_clue)):
		PalaceManager.instance.create_thought(dragged_clue);
		UIManager.instance.clear_mind_palace_ui();
		UIManager.instance.update_mind_palace_ui();
	return;

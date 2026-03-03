class_name UIManager
extends Node

static var instance: UIManager;

@export var note_ui: CanvasLayer;
@export var added_thought_notif: CanvasLayer;
@export var mind_palace_ui: CanvasLayer;
@export var thought_ui: Resource;
@export var thought_path_ui: Resource;

var instanciated_thought_uis: Array[ThoughtUI] = [null];
var thought_uis_count: int = 0;

var instanciated_thought_path_uis: Array[Button] = [null];
var thought_path_uis_count: int = 0;

var cursor_locked_menu: bool = true;
var cursor_locked_game: bool = true;

var is_note_ui_active: bool = false;
var is_mind_palace_ui_active: bool = false;

var is_in_esc_menu: bool = false;
var is_in_game: bool = true;

var chosen_thought_path: ThoughtPath = null;

func _ready() -> void:
	if(instance == null):
		instance = self;    
		if(note_ui != null): remove_child(note_ui);
		if(added_thought_notif != null): remove_child(added_thought_notif);
		if(mind_palace_ui != null): remove_child(mind_palace_ui);
		update_cursor();
	else:
		print("More than one UIManager exists!!!");
		queue_free();

func _process(_delta: float) -> void:
	# if(Input.is_action_just_pressed("ui_cancel") && is_note_ui_active):
	# 	hide_note_ui();
	if(Input.is_action_just_pressed("Mind Palace") && mind_palace_ui != null && !is_note_ui_active && !is_in_esc_menu):
		if(is_mind_palace_ui_active): hide_mind_palace_ui();
		else: show_mind_palace_ui();
		is_mind_palace_ui_active = !is_mind_palace_ui_active;

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == Key.KEY_ESCAPE:
			if(is_note_ui_active): return;
			cursor_locked_menu = !cursor_locked_menu;
			is_in_esc_menu = !is_in_esc_menu;
			update_cursor();
	if(mind_palace_ui == null): return;
		
func show_added_thought_notif(new_clue: Clue, time: float):
	if(!has_node("AddedThoughtNotif")): add_child(added_thought_notif);
	added_thought_notif.get_node("RichTextLabel").text = new_clue.name;
	var temp_text = new_clue.name;
	await get_tree().create_timer(time).timeout;
	if(temp_text != added_thought_notif.get_node("RichTextLabel").text): return;
	remove_child(added_thought_notif);

func get_clue_at(pos: Vector2) -> Clue:
	for i in range(0, thought_uis_count):
		var thought: Node = instanciated_thought_uis[i];
		if(pos.x > thought.position.x && pos.x < thought.position.x + thought.size.x):
			if(pos.y > thought.position.y && pos.y < thought.position.y + thought.size.y):
				return instanciated_thought_uis[i].thought_clue;
	return null;

func get_thought_ui_at(pos: Vector2) -> ThoughtUI:
	for i in range(0, thought_uis_count):
		var thought: Node = instanciated_thought_uis[i];
		if(pos.x > thought.position.x && pos.x < thought.position.x + thought.size.x):
			if(pos.y > thought.position.y && pos.y < thought.position.y + thought.size.y):
				return instanciated_thought_uis[i];
	return null;

func show_mind_palace_ui():
	is_in_game = false;
	add_child(mind_palace_ui);
	update_mind_palace_ui();
	cursor_locked_game = false;
	update_cursor();

func update_mind_palace_ui():
	for i in range(0, PalaceManager.instance.thought_paths.size()):
		if(!PalaceManager.instance.thought_paths[i].is_unlocked()): continue;
		var thought_path_ui_instance = thought_path_ui.instantiate();
		mind_palace_ui.get_node("ThoughtPaths").add_child(thought_path_ui_instance);
		thought_path_ui_instance.text = PalaceManager.instance.thought_paths[i].name;
		thought_path_ui_instance.pressed.connect(choose_thought_path.bind(PalaceManager.instance.thought_paths[i])	);
		thought_path_ui_instance.position = Vector2(0, 720 - i * 96);
		instanciated_thought_path_uis[thought_path_uis_count] = thought_path_ui_instance;
		thought_path_uis_count += 1;
		if(instanciated_thought_path_uis.size() == thought_path_uis_count):
			instanciated_thought_path_uis.resize(thought_path_uis_count * 2);

	for i in range(0, PalaceManager.instance.first_free_index):
		# print("spawning thought ui");
		var thought_ui_instance = thought_ui.instantiate();
		mind_palace_ui.get_node("Panel").add_child(thought_ui_instance);
		var current_clue: Clue = PalaceManager.instance.gathered_clues[i];
		thought_ui_instance.set_thought_ui_instance(current_clue.name, current_clue.description, 240 + i * 240, 540, current_clue, false);
		instanciated_thought_uis[thought_uis_count] = thought_ui_instance;
		thought_uis_count += 1;
		if(instanciated_thought_uis.size() == thought_uis_count):
			instanciated_thought_uis.resize(thought_uis_count * 2);
	print(chosen_thought_path == null);
	if(chosen_thought_path == null): return
	# for j in range(0, PalaceManager.instance.thought_paths.size()):
	for i in range(0, chosen_thought_path.required_clues.size()):
		if(!chosen_thought_path.is_clue_realized[i]): break;
		var thought_ui_instance = thought_ui.instantiate();
		mind_palace_ui.get_node("Panel").add_child(thought_ui_instance);
		var current_clue: Clue = chosen_thought_path.required_clues[i];
		thought_ui_instance.set_thought_ui_instance(current_clue.name, current_clue.description, 240 + i * 240, 240, current_clue, true);
		instanciated_thought_uis[thought_uis_count] = thought_ui_instance;
		thought_uis_count += 1;
		if(instanciated_thought_uis.size() == thought_uis_count):
			instanciated_thought_uis.resize(thought_uis_count * 2);

func clear_mind_palace_ui():
	for i in range(thought_uis_count - 1, -1, -1): #-1 bo koniec jest exlusive wiec idzie do 0
		instanciated_thought_uis[i].queue_free();
		# print("destroyed thought ui");
	instanciated_thought_uis = [null];
	thought_uis_count = 0;

	for i in range(thought_path_uis_count - 1, -1, -1):
		instanciated_thought_path_uis[i].queue_free();
		# print("destroyed thought ui");
	instanciated_thought_path_uis = [null];
	thought_path_uis_count = 0;

func choose_thought_path(path: ThoughtPath):
	print("Chosen: " + path.name);
	chosen_thought_path = path;
	clear_mind_palace_ui();
	update_mind_palace_ui();

func hide_mind_palace_ui():
	is_in_game = true;
	remove_child(mind_palace_ui);
	clear_mind_palace_ui();
	cursor_locked_game = true;
	update_cursor();

func show_note_ui(note_content: String) -> void:
	is_note_ui_active = true;
	is_in_game = false;
	add_child(note_ui);
	note_ui.get_node("RichTextLabel").text = note_content;
	cursor_locked_game = false;
	update_cursor();

func hide_note_ui() -> void:
	is_note_ui_active = false;
	is_in_game = true;
	remove_child(note_ui);
	cursor_locked_game = true;
	update_cursor();

func update_cursor() -> void:
	if(!cursor_locked_game || !cursor_locked_menu):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		print("Cursor unlocked");
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
		print("Cursor locked");

class_name UIManager
extends Node

static var instance: UIManager;

@export var note_ui: CanvasLayer;
@export var added_thought_notif: CanvasLayer;
@export var mind_palace_ui: CanvasLayer;
@export var thought_ui: Resource;
@export var thought_path_ui: Resource;
@export var esc_menu: CanvasLayer;
@export var game_over_screen: CanvasLayer;
var game_over_controls: Control;
var controls_menu: Control;

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

var rocks_label: Label
var serum_label: Label

func _ready() -> void:
	if(instance == null):
		instance = self;    
		remove_child(note_ui);
		remove_child(added_thought_notif);
		
		rocks_label = mind_palace_ui.get_node("Inventory/Rock");
		serum_label = mind_palace_ui.get_node("Inventory/Serum");
		remove_child(mind_palace_ui);

		var button: Button = esc_menu.get_node("Panel/Resume");
		button.pressed.connect(resume_game);
		button.process_mode = Node.PROCESS_MODE_ALWAYS;
		var button2: Button = esc_menu.get_node("Panel/Checkpoint");
		button2.pressed.connect(reload_last_checkpoint);
		button2.process_mode = Node.PROCESS_MODE_ALWAYS;
		var button3: Button = esc_menu.get_node("Panel/Controls");
		button3.pressed.connect(show_controls);
		button3.process_mode = Node.PROCESS_MODE_ALWAYS;
		controls_menu = esc_menu.get_node("ControlsPanel");
		var button4: Button = controls_menu.get_node("Close");
		button4.pressed.connect(hide_controls);
		button4.process_mode = Node.PROCESS_MODE_ALWAYS;
		esc_menu.remove_child(controls_menu);
		remove_child(esc_menu);

		var button5: Button = game_over_screen.get_node("Panel/Checkpoint");
		button5.pressed.connect(game_over_load_checkpoint);
		button5.process_mode = Node.PROCESS_MODE_ALWAYS;
		var button6: Button = game_over_screen.get_node("Panel/Controls");
		button6.pressed.connect(show_game_over_controls);
		button6.process_mode = Node.PROCESS_MODE_ALWAYS;
		game_over_controls = game_over_screen.get_node("ControlsPanel");
		var button7: Button = game_over_controls.get_node("Close");
		button7.pressed.connect(hide_game_over_controls);
		button7.process_mode = Node.PROCESS_MODE_ALWAYS;
		game_over_screen.remove_child(game_over_controls);
		remove_child(game_over_screen);

		# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED); 
		# Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN); 
		process_mode = Node.PROCESS_MODE_ALWAYS;
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
	if(GameManager.instance.is_game_over): return;
	if event is InputEventKey:
		if event.pressed and event.keycode == Key.KEY_ESCAPE:
			is_in_esc_menu = !is_in_esc_menu;
			if(is_in_esc_menu): 
				cursor_locked_menu = false;
				add_child(esc_menu);
				GameManager.instance.pause_game();
				update_cursor();
			else: 
				resume_game();


func resume_game() -> void:
	hide_controls();
	cursor_locked_menu = true;
	is_in_esc_menu = false;
	remove_child(esc_menu);
	GameManager.instance.unpause_game();
	update_cursor();

func reload_last_checkpoint() -> void:
	SaveManager.instance.load_last_checkpoint();
	resume_game();

func game_over_load_checkpoint():
	hide_game_over();
	GameManager.instance.restart_scene();

func show_game_over() -> void:
	add_child(game_over_screen);
	cursor_locked_menu = false;
	update_cursor();

func hide_game_over() -> void:
	remove_child(game_over_screen);
	cursor_locked_menu = true;
	update_cursor();

func show_controls() -> void:
	esc_menu.add_child(controls_menu);

func hide_controls() -> void:
	esc_menu.remove_child(controls_menu);

func show_game_over_controls() -> void:
	game_over_screen.add_child(game_over_controls);

func hide_game_over_controls() -> void:
	game_over_screen.remove_child(game_over_controls);

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

	rocks_label.text = str(InventoryManager.instance.itemCount[ITEM_TYPE.ROCK]) + "x Kamieni";
	serum_label.text = str(InventoryManager.instance.itemCount[ITEM_TYPE.SERUM]) + "x Serum";

	for i in range(0, PalaceManager.instance.thought_paths.size()):
		if(!PalaceManager.instance.thought_paths[i].is_unlocked()): continue;
		var thought_path_ui_instance = thought_path_ui.instantiate();
		mind_palace_ui.get_node("ThoughtPaths").add_child(thought_path_ui_instance);
		thought_path_ui_instance.text = PalaceManager.instance.thought_paths[i].name;
		thought_path_ui_instance.pressed.connect(choose_thought_path.bind(PalaceManager.instance.thought_paths[i]));
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
		print(current_clue.description);
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
		thought_ui_instance.set_thought_ui_instance(current_clue.name, current_clue.description, 0, 0, current_clue, true);
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
		# bawie sie z tym na razie
		# mi na linuxie i z wayland to działa jedynie, później na windowsa może się zmieni na Input.MOUSE_MODE_CAPTURED
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED); 
		# Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN); 
		print("Cursor locked");

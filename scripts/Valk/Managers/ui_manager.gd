class_name UIManager
extends Node

static var instance: UIManager;

# @export var note_ui: CanvasLayer;
@export var added_thought_notif: CanvasLayer;
@export var mind_palace_ui: CanvasLayer;
@export var thought_ui: Resource;
@export var thought_path_ui: Resource;
@export var notes_ui: CanvasLayer;
@export var esc_menu: CanvasLayer;
@export var game_over_screen: CanvasLayer;
@export var bad_ending_screen: CanvasLayer;
@export var good_ending_screen: CanvasLayer;
@export var black_transition: CanvasLayer;
var game_over_controls: Control;
var controls_menu: Control;

var instanciated_thought_uis: Array[ThoughtUI] = [null];
var thought_uis_count: int = 0;

var instanciated_thought_path_uis: Array[Button] = [null];
var thought_path_uis_count: int = 0;

var cursor_locked_menu: bool = true;
var cursor_locked_game: bool = true;

# var is_note_ui_active: bool = false;
var is_mind_palace_ui_active: bool = false;
var is_notes_ui_active: bool = false;

var is_in_esc_menu: bool = false;
var is_in_game: bool = true;

var chosen_thought_path: ThoughtPath = null;
var chosen_note: Note = null;

var rocks_label: Label
var serum_label: Label

var transitioned: bool = false;
@export var transition_speed: float = 1.0;

var transition_to_main_menu_started: bool = false;
@export var main_menu_transition_speed: float = 1.0;

var was_note_ui_last_opened: bool = false;
# @export var main_scene: PackedScene;

func _ready() -> void:
	if(instance == null):
		instance = self;    
		# remove_child(note_ui);
		remove_child(added_thought_notif);
		
		rocks_label = mind_palace_ui.get_node("Inventory/Rock");
		serum_label = mind_palace_ui.get_node("Inventory/Serum");
		var notes_ui_button: Button = mind_palace_ui.get_node("ThoughtPaths/Button2");
		notes_ui_button.pressed.connect(switch_to_notes_ui_panel);
		remove_child(mind_palace_ui);

		var mind_palace_ui_button: Button = notes_ui.get_node("ThoughtPaths/Button");
		mind_palace_ui_button.pressed.connect(switch_to_mind_palace_ui_panel);
		remove_child(notes_ui);

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
		var button9: Button = esc_menu.get_node("Panel/MainMenu");
		button9.pressed.connect(go_to_main_menu);
		button9.process_mode = Node.PROCESS_MODE_ALWAYS;
		esc_menu.remove_child(controls_menu);
		remove_child(esc_menu);

		var button5: Button = game_over_screen.get_node("Panel/Checkpoint");
		button5.pressed.connect(reload_last_checkpoint);
		button5.process_mode = Node.PROCESS_MODE_ALWAYS;
		var button6: Button = game_over_screen.get_node("Panel/Controls");
		button6.pressed.connect(show_game_over_controls);
		button6.process_mode = Node.PROCESS_MODE_ALWAYS;
		game_over_controls = game_over_screen.get_node("ControlsPanel");
		var button7: Button = game_over_controls.get_node("Close");
		button7.pressed.connect(hide_game_over_controls);
		button7.process_mode = Node.PROCESS_MODE_ALWAYS;
		game_over_screen.remove_child(game_over_controls);
		var button11: Button = game_over_screen.get_node("Panel/MainMenu");
		button11.pressed.connect(go_to_main_menu);
		button11.process_mode = Node.PROCESS_MODE_ALWAYS;
		remove_child(game_over_screen);

		var button8: Button = bad_ending_screen.get_node("Panel/MainMenu");
		button8.pressed.connect(go_to_main_menu);
		remove_child(bad_ending_screen);
		var button10: Button = good_ending_screen.get_node("Panel/MainMenu");
		button10.pressed.connect(go_to_main_menu);
		remove_child(good_ending_screen);

		EventBus.bad_ending.connect(show_bad_ending_screen);
		EventBus.good_ending.connect(show_good_ending_screen);
		process_mode = Node.PROCESS_MODE_ALWAYS;
		update_cursor();
		transition_to_main_menu_started = false;
	else:
		print("More than one UIManager exists!!!");
		queue_free();

func go_to_main_menu():
	add_child(black_transition)
	black_transition.get_node("ColorRect").color.a = 0;
	transition_to_main_menu_started = true;
	EventBus.reset_signal_subscribers();

func show_bad_ending_screen():
	PsycheManager.instance.set_vignette_parameters(0, Color.ALICE_BLUE, 0);
	GameManager.instance.is_game_over = true;
	GameManager.instance.pause_game();
	cursor_locked_menu = false;
	update_cursor();
	add_child(bad_ending_screen);

func show_good_ending_screen():
	await get_tree().create_timer(5.0, false).timeout;
	PsycheManager.instance.set_vignette_parameters(0, Color.ALICE_BLUE, 0);
	GameManager.instance.is_game_over = true;
	GameManager.instance.pause_game();
	cursor_locked_menu = false;
	update_cursor();
	add_child(good_ending_screen);

func _process(delta: float) -> void:
	if(transition_to_main_menu_started):
		black_transition.get_node("ColorRect").color.a += (1/main_menu_transition_speed) * delta;
		if(black_transition.get_node("ColorRect").color.a >= 1.0):
			GameManager.instance.unpause_game();
			print(get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"));
	if(!transitioned):
		black_transition.get_node("ColorRect").color.a -= (1/transition_speed) * delta;
		if(black_transition.get_node("ColorRect").color.a < 0):
			remove_child(black_transition);
			transitioned = true;

	if(Input.is_action_just_pressed("Mind Palace") && !is_in_esc_menu):
		if(is_mind_palace_ui_active): 
			was_note_ui_last_opened = false;
			hide_mind_palace_ui();
		elif(is_notes_ui_active): 
			was_note_ui_last_opened = true;
			hide_notes_ui();
		else: 
			if(was_note_ui_last_opened):
				show_notes_ui();
			else:
				show_mind_palace_ui();
	
	if(Input.is_action_just_pressed("Switch UI Panel Left")):
		if(is_mind_palace_ui_active):
			switch_to_notes_ui_panel();
		elif(is_notes_ui_active):
			switch_to_mind_palace_ui_panel();

	if(Input.is_action_just_pressed("Switch to Lower Path")):
		switch_to_lower_ui_path();
	if(Input.is_action_just_pressed("Switch to Higher Path")):
		switch_to_higher_ui_path();

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

func switch_to_notes_ui_panel():
	remove_child(mind_palace_ui);
	clear_mind_palace_ui();
	is_mind_palace_ui_active = false;
	add_child(notes_ui);
	update_notes_ui();
	is_notes_ui_active = true;

func switch_to_mind_palace_ui_panel():
	remove_child(notes_ui);
	clear_notes_ui();
	is_notes_ui_active = false;
	add_child(mind_palace_ui);
	update_mind_palace_ui();
	is_mind_palace_ui_active = true;

func switch_to_lower_ui_path():
	var index: int = -1;
	if(is_mind_palace_ui_active):
		index = PalaceManager.instance.get_thought_path_index(chosen_thought_path);
		if(index == -1): return;
		index -= 1;
		if(index == -1):
			index = PalaceManager.instance.thought_paths.size() - 1;
		for i in range(index, -1, -1):
			if(PalaceManager.instance.thought_paths[i].is_unlocked()):
				index = i;
				break;
		choose_thought_path(PalaceManager.instance.thought_paths[index]);
	elif(is_notes_ui_active):
		index = PalaceManager.instance.get_note_index(chosen_note);
		if(index == -1): return;
		index -= 1;
		if(index == -1):
			index = PalaceManager.instance.first_note_free_index - 1;
		choose_note_ui(PalaceManager.instance.gathered_notes[index]);

func switch_to_higher_ui_path():
	var index: int = -1;
	if(is_mind_palace_ui_active):
		index = PalaceManager.instance.get_thought_path_index(chosen_thought_path);
		if(index == -1): return;
		index += 1;
		if(index == PalaceManager.instance.thought_paths.size()):
			index = 0;
		for i in range(index, PalaceManager.instance.thought_paths.size() - 1):
			if(PalaceManager.instance.thought_paths[i].is_unlocked()):
				index = i;
				break;
		if(!PalaceManager.instance.thought_paths[index].is_unlocked()):
			for i in range(0, PalaceManager.instance.thought_paths.size() - 1):
				if(PalaceManager.instance.thought_paths[i].is_unlocked()):
					index = i;
					break;
		choose_thought_path(PalaceManager.instance.thought_paths[index]);
	elif(is_notes_ui_active):
		index = PalaceManager.instance.get_note_index(chosen_note);
		if(index == -1): return;
		index += 1;
		if(index == PalaceManager.instance.first_note_free_index):
			index = 0;
		choose_note_ui(PalaceManager.instance.gathered_notes[index]);

func resume_game() -> void:
	hide_controls();
	cursor_locked_menu = true;
	is_in_esc_menu = false;
	remove_child(esc_menu);
	GameManager.instance.unpause_game();
	update_cursor();

func reload_last_checkpoint() -> void:
	if(GameManager.instance.is_game_over): hide_game_over();
	GameManager.instance.restart_scene();
	EventBus.reset_signal_subscribers();

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
	added_thought_notif.get_node("ColorRect/RichTextLabel").text = new_clue.name;
	var temp_text = new_clue.name;
	await get_tree().create_timer(time).timeout;
	if(temp_text != added_thought_notif.get_node("ColorRect/RichTextLabel").text): return;
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
	is_mind_palace_ui_active = true;

func update_mind_palace_ui():
	rocks_label.text = str(InventoryManager.instance.itemCount[ITEM_TYPE.ROCK]) + "x Kamieni";
	serum_label.text = str(InventoryManager.instance.itemCount[ITEM_TYPE.SERUM]) + "x Serum";

	if(chosen_thought_path == null):
		for i in range(0, PalaceManager.instance.thought_paths.size()):
			if(PalaceManager.instance.thought_paths[i].is_unlocked()):
				chosen_thought_path = PalaceManager.instance.thought_paths[i];
				break;

	for i in range(0, PalaceManager.instance.thought_paths.size()):
		if(!PalaceManager.instance.thought_paths[i].is_unlocked()): continue;
		var thought_path_ui_instance = thought_path_ui.instantiate();
		mind_palace_ui.get_node("ThoughtPaths").add_child(thought_path_ui_instance);
		thought_path_ui_instance.text = PalaceManager.instance.thought_paths[i].name;
		thought_path_ui_instance.pressed.connect(choose_thought_path.bind(PalaceManager.instance.thought_paths[i]));
		thought_path_ui_instance.position = Vector2(32, 768 - i * 96);
		if(PalaceManager.instance.thought_paths[i] == chosen_thought_path):
			var style: StyleBox = thought_path_ui_instance.get_theme_stylebox("normal").duplicate();
			style.set_bg_color(Color(0.9, 0.9, 0.9));
			thought_path_ui_instance.add_theme_stylebox_override("normal", style);
			thought_path_ui_instance.add_theme_color_override("font_hover_color", Color.BLACK);

			var style_hover: StyleBox = thought_path_ui_instance.get_theme_stylebox("hover").duplicate();
			style_hover.set_bg_color(Color.WHITE);
			thought_path_ui_instance.add_theme_stylebox_override("hover", style_hover);
			thought_path_ui_instance.add_theme_color_override("font_color", Color.BLACK);

		instanciated_thought_path_uis[thought_path_uis_count] = thought_path_ui_instance;
		thought_path_uis_count += 1;
		if(instanciated_thought_path_uis.size() == thought_path_uis_count):
			instanciated_thought_path_uis.resize(thought_path_uis_count * 2);

	for i in range(0, PalaceManager.instance.first_free_index):
		# print("spawning thought ui");
		var thought_ui_instance = thought_ui.instantiate();
		mind_palace_ui.get_node("Panel").add_child(thought_ui_instance);
		var current_clue: Clue = PalaceManager.instance.gathered_clues[i];
		thought_ui_instance.set_thought_ui_instance(current_clue.name, current_clue.description, 32 + i * 192, 608, current_clue, false, current_clue.connected_note);
		instanciated_thought_uis[thought_uis_count] = thought_ui_instance;
		thought_uis_count += 1;
		if(instanciated_thought_uis.size() == thought_uis_count):
			instanciated_thought_uis.resize(thought_uis_count * 2);

	if(chosen_thought_path == null): return;

	var thought_path_title: Label = mind_palace_ui.get_node("Panel2/Title");
	thought_path_title.text = chosen_thought_path.name;

	for i in range(0, chosen_thought_path.required_clues.size()):
		if(!chosen_thought_path.is_clue_realized[i]): continue;
		var thought_ui_instance = thought_ui.instantiate();
		mind_palace_ui.get_node("Panel").add_child(thought_ui_instance);
		var current_clue: Clue = chosen_thought_path.required_clues[i];
		thought_ui_instance.set_thought_ui_instance(current_clue.name, current_clue.description, 0, 0, current_clue, true, current_clue.connected_note);
		instanciated_thought_uis[thought_uis_count] = thought_ui_instance;
		thought_uis_count += 1;
		if(instanciated_thought_uis.size() == thought_uis_count):
			instanciated_thought_uis.resize(thought_uis_count * 2);

func clear_mind_palace_ui():
	for i in range(thought_uis_count - 1, -1, -1):
		instanciated_thought_uis[i].queue_free();
		# print("destroyed thought ui");
	instanciated_thought_uis = [null];
	thought_uis_count = 0;

	for i in range(thought_path_uis_count - 1, -1, -1):
		instanciated_thought_path_uis[i].queue_free();
		# print("destroyed thought ui");
	instanciated_thought_path_uis = [null];
	thought_path_uis_count = 0;

func hide_mind_palace_ui():
	is_in_game = true;
	remove_child(mind_palace_ui);
	clear_mind_palace_ui();
	cursor_locked_game = true;
	update_cursor();
	is_mind_palace_ui_active = false;

func show_notes_ui():
	is_in_game = false;
	add_child(notes_ui);
	update_notes_ui();
	cursor_locked_game = false;
	update_cursor();
	is_notes_ui_active = true;

func update_notes_ui():
	notes_ui.get_node("Inventory/Rock").text = str(InventoryManager.instance.itemCount[ITEM_TYPE.ROCK]) + "x Kamieni";
	notes_ui.get_node("Inventory/Serum").text = str(InventoryManager.instance.itemCount[ITEM_TYPE.SERUM]) + "x Serum";

	for i in range(0, PalaceManager.instance.first_note_free_index):
		var thought_path_ui_instance = thought_path_ui.instantiate();
		notes_ui.get_node("ThoughtPaths").add_child(thought_path_ui_instance);
		thought_path_ui_instance.text = PalaceManager.instance.gathered_notes[i].title;
		thought_path_ui_instance.pressed.connect(choose_note_ui.bind(PalaceManager.instance.gathered_notes[i]));
		thought_path_ui_instance.position = Vector2(32, 768 - i * 96);
		if(PalaceManager.instance.gathered_notes[i] == chosen_note):
			var style: StyleBox = thought_path_ui_instance.get_theme_stylebox("normal").duplicate();
			style.set_bg_color(Color(0.9, 0.9, 0.9));
			thought_path_ui_instance.add_theme_stylebox_override("normal", style);
			thought_path_ui_instance.add_theme_color_override("font_hover_color", Color.BLACK);

			var style_hover: StyleBox = thought_path_ui_instance.get_theme_stylebox("hover").duplicate();
			style_hover.set_bg_color(Color.WHITE);
			thought_path_ui_instance.add_theme_stylebox_override("hover", style_hover);
			thought_path_ui_instance.add_theme_color_override("font_color", Color.BLACK);

		instanciated_thought_path_uis[thought_path_uis_count] = thought_path_ui_instance;
		thought_path_uis_count += 1;
		if(instanciated_thought_path_uis.size() == thought_path_uis_count):
			instanciated_thought_path_uis.resize(thought_path_uis_count * 2);
	
	if(chosen_note == null): 
		notes_ui.get_node("CurrentNoteUI").visible = false;
		notes_ui.get_node("Panel2/Title").text = "Nie zebrano żadnej notatki"
		return;
	notes_ui.get_node("CurrentNoteUI").visible = true;
	notes_ui.get_node("CurrentNoteUI/RichTextLabel").text = chosen_note.content;

	var note_title: Label = notes_ui.get_node("Panel2/Title");
	note_title.text = chosen_note.title;


func clear_notes_ui():
	for i in range(thought_path_uis_count - 1, -1, -1):
		instanciated_thought_path_uis[i].queue_free();
	instanciated_thought_path_uis = [null];
	thought_path_uis_count = 0;

func hide_notes_ui():
	is_in_game = true;
	remove_child(notes_ui);
	clear_notes_ui();
	cursor_locked_game = true;
	update_cursor();
	is_notes_ui_active = false;

func choose_thought_path(path: ThoughtPath):
	chosen_thought_path = path;
	clear_mind_palace_ui();
	update_mind_palace_ui();

func choose_note_ui(note: Note):
	chosen_note = note;
	clear_notes_ui();
	update_notes_ui();

func update_cursor() -> void:
	if(!cursor_locked_game || !cursor_locked_menu):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		# print("Cursor unlocked");
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED); 
		# print("Cursor locked");

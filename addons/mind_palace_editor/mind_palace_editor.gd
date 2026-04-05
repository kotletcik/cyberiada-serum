@tool
extends EditorPlugin

var dock
var dock_control
var clue_ui
var clue_ui_start_y_pos = 32;
var y_pos = 32;

var folder_ui

var index = 0;

var clue_ui_instances: Array[EditorClueUI] = [null];
var first_free_index: int = 0;

var folder_ui_instances: Array[EditorFolderUI] = [null];
var first_folder_free_index: int = 0;

var root_path = "res://resources/thought_paths/";

var current_thought_path = null;

var is_loading = false;

var last_width;
var hbox: HBoxContainer;

# func _enable_plugin():
# 	# add_autoload_singleton("EditorEventBus", "res://scripts/Valk/Tools/editor_event_bus.gd")

# func _disable_plugin():
# 	# remove_autoload_singleton("EditorEventBus")

func create_field(clue: Clue):
	var clue_ui_instance = clue_ui.instantiate();
	var control = clue_ui_instance as EditorClueUI;

	control.set_clue_ui_instance(clue, index);
	control.position.y = y_pos;
	control.position.x = 0;

	dock.get_node("PluginUI").add_child(clue_ui_instance);
	clue_ui_instances[first_free_index] = clue_ui_instance;
	first_free_index += 1;
	if(first_free_index == clue_ui_instances.size()):
		clue_ui_instances.resize(first_free_index * 2);

	y_pos += 32;
	index += 1;

func create_folder_ui(path: ThoughtPath):
	var folder_ui_instance = folder_ui.instantiate();
	var button = folder_ui_instance as EditorFolderUI;

	button.set_folder_ui_instance(path, change_current_folder);
	dock.get_node("PluginUI/HBoxContainer").add_child(folder_ui_instance);

	folder_ui_instances[first_folder_free_index] = folder_ui_instance;
	first_folder_free_index += 1;
	if(first_folder_free_index == folder_ui_instances.size()):
		folder_ui_instances.resize(first_folder_free_index * 2);

func change_current_folder(path: ThoughtPath):
	current_thought_path = path
	update_plugin_ui("change_current_thought_path");

func update_folders_ui():
	if(is_loading): return;
	var files = DirAccess.get_files_at(root_path);

	is_loading = true;

	var thoughts_paths: Array[ThoughtPath] = [null];
	var length = files.size();
	thoughts_paths.resize(length);
	for i in range(0, length):
		var thought_path: ThoughtPath = ResourceLoader.load(root_path + files[i]);
		thoughts_paths[i] = thought_path;

	is_loading = false;

	for i in range(0, length):
		create_folder_ui(thoughts_paths[i]);

	if(current_thought_path == null && length > 0):
		current_thought_path = thoughts_paths[0];
	
	dock.get_node("PluginUI/HBoxContainer").size.x = dock_control.size.x;

func update_plugin_ui(caller: String):
	# print(caller);
	y_pos = clue_ui_start_y_pos;
	# print("plugin ui updated");
	clear_plugin_ui();
	update_folders_ui();
	update_content_ui();

func update_content_ui():
	if(is_loading): return;
	# print("	UPDATING CONTENT UI");
	index = 0;
	for i in range(0, current_thought_path.required_clues.size()):
		create_field(current_thought_path.required_clues[i]);

func refresh_content_ui():
	# print("signal refresh");
	for i in range(first_free_index - 1, -1, -1):
		clue_ui_instances[i].queue_free();
	clue_ui_instances = [null];
	first_free_index = 0;

	y_pos = clue_ui_start_y_pos;
	update_content_ui();

func clear_plugin_ui():
	for i in range(first_free_index - 1, -1, -1):
		clue_ui_instances[i].queue_free();
	clue_ui_instances = [null];
	first_free_index = 0;

	for i in range(first_folder_free_index - 1, -1, -1):
		folder_ui_instances[i].queue_free();
	folder_ui_instances = [null];
	first_folder_free_index = 0;

func _ready():
	hbox = dock.get_node("PluginUI/HBoxContainer");

func _process(delta: float):
	var width = dock_control.size.x;
	if(width != last_width):
		hbox.size.x = width;
		last_width = width;

func _enter_tree():
	dock = EditorDock.new()
	dock.title = "Mind Palace Editor"
	var plugin_ui = preload("res://addons/mind_palace_editor/ui/plugin_ui.tscn").instantiate() as Control;
	dock.add_child(plugin_ui);

	dock_control = dock as Control
	clue_ui = preload("res://addons/mind_palace_editor/ui/clue_ui.tscn");
	folder_ui = preload("res://addons/mind_palace_editor/ui/folder_ui.tscn");
	update_plugin_ui("enter_tree");

	dock.default_slot = EditorDock.DOCK_SLOT_LEFT_UL
	dock.available_layouts = EditorDock.DOCK_LAYOUT_VERTICAL | EditorDock.DOCK_LAYOUT_FLOATING

	add_dock(dock)
	EditorEventBus.mind_palace_editor_refresh.connect(refresh_content_ui);

func _exit_tree():
	EditorEventBus.mind_palace_editor_refresh.disconnect(refresh_content_ui);
	remove_dock(dock)
	dock.queue_free()
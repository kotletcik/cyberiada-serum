@tool
extends EditorPlugin


# A class member to hold the dock during the plugin life cycle.
var dock
var clue_ui
var clue_ui_start_y_pos = 32;
var y_pos = 32;

var folder_ui

var index = 0;

var clue_ui_instances: Array[EditorClueUI] = [null];
var first_free_index: int = 0;

var folder_ui_instances: Array[EditorFolderUI] = [null];
var first_folder_free_index: int = 0;

var root_path = "res://resources/thoughts/";

var current_folder = "shell";

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

func create_folder_ui(name: String):
	var folder_ui_instance = folder_ui.instantiate();
	var button = folder_ui_instance as EditorFolderUI;

	button.set_folder_ui_instance(name, change_current_folder);
	dock.get_node("PluginUI/HBoxContainer").add_child(folder_ui_instance);

	folder_ui_instances[first_folder_free_index] = folder_ui_instance;
	first_folder_free_index += 1;
	if(first_folder_free_index == folder_ui_instances.size()):
		folder_ui_instances.resize(first_folder_free_index * 2);

func change_current_folder(folder: String):
	current_folder = folder
	update_plugin_ui();

func update_folders_ui():
	var dock_control = dock as Control
	var width = dock_control.size.x;
	dock.get_node("PluginUI/HBoxContainer").size.x = width;

	var dir = DirAccess.open(root_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				# print("Found directory: " + file_name)
				create_folder_ui(file_name);
			else:
				pass
				# print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func update_plugin_ui():
	y_pos = clue_ui_start_y_pos;
	# print("plugin ui updated");
	clear_plugin_ui();
	update_folders_ui();
	update_content_ui();

func update_content_ui():
	# print("updating content ui");
	var dir = DirAccess.open(root_path + current_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
				# print("Found directory: " + file_name)
			else:
				# print("Found file: " + file_name)
				var clue: Clue = ResourceLoader.load(root_path + current_folder + "/" + file_name);
				create_field(clue);
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func clear_plugin_ui():
	for i in range(first_free_index - 1, -1, -1):
		clue_ui_instances[i].queue_free();
	clue_ui_instances = [null];
	first_free_index = 0;

	for i in range(first_folder_free_index - 1, -1, -1):
		folder_ui_instances[i].queue_free();
	folder_ui_instances = [null];
	first_folder_free_index = 0;

func _enter_tree():
	# Initialization of the plugin goes here.
	# Load the dock scene and instantiate it.

	# Create the dock and add the loaded scene to it.
	dock = EditorDock.new()
	dock.title = "Mind Palace Editor"
	var plugin_ui = preload("res://addons/mind_palace_editor/ui/plugin_ui.tscn").instantiate() as Control;
	dock.add_child(plugin_ui);

	clue_ui = preload("res://addons/mind_palace_editor/ui/clue_ui.tscn");
	folder_ui = preload("res://addons/mind_palace_editor/ui/folder_ui.tscn");
	update_plugin_ui();

	# Note that LEFT_UL means the left of the editor, upper-left dock.
	dock.default_slot = EditorDock.DOCK_SLOT_LEFT_UL

	# Allow the dock to be on the left or right of the editor, and to be made floating.
	dock.available_layouts = EditorDock.DOCK_LAYOUT_VERTICAL | EditorDock.DOCK_LAYOUT_FLOATING

	add_dock(dock)
	EditorEventBus.mind_palace_editor_refresh.connect(update_plugin_ui);

    
func _exit_tree():
	EditorEventBus.mind_palace_editor_refresh.disconnect(update_plugin_ui);
	# Clean-up of the plugin goes here.
	# Remove the dock.
	remove_dock(dock)
	# Erase the control from the memory.
	dock.queue_free()
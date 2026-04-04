@tool
class_name EditorFolderUI
extends Button

var set_clue: Clue = null

func set_folder_ui_instance(name: String, call: Callable):
    text = name;
    pressed.connect(call.bind(name));
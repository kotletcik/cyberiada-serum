@tool
class_name EditorFolderUI
extends Button

var set_thought_path: ThoughtPath = null

func set_folder_ui_instance(path: ThoughtPath, call: Callable):
    text = path.name;
    set_thought_path = path;
    pressed.connect(call.bind(set_thought_path));
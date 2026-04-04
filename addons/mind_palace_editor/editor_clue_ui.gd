@tool
class_name EditorClueUI
extends Panel

var set_clue: Clue = null

var setting_instance: bool = false;

func set_clue_ui_instance(clue: Clue, index: int):
    if(setting_instance): return;
    if(clue == null):
        get_node("Name").text = "Null" + str(index);
        return;
    setting_instance = true;
    set_clue = clue;
    get_node("Name").text = clue.name;
    get_node("CheckBox").button_pressed = clue.automatically_unlock;
    get_node("CheckBox").toggled.connect(change_automatically_unlock);
    get_node("CheckBox2").button_pressed = clue.required_for_realization;
    get_node("CheckBox2").toggled.connect(change_required_for_realization);
    get_node("Button").pressed.connect(open_in_inspector);
    setting_instance = false;

func change_automatically_unlock(value: bool):
    if(setting_instance): return;
    print("automatically_unlock: " + str(value));
    set_clue.automatically_unlock = value;
    ResourceSaver.save(set_clue);

func change_required_for_realization(value: bool):
    if(setting_instance): return;
    print("required_for_realization: " + str(value));
    set_clue.required_for_realization = value;
    ResourceSaver.save(set_clue);

func open_in_inspector():
    if(set_clue == null): return;
    EditorInterface.get_inspector().edit(set_clue);

@tool
class_name EditorClueUI
extends Panel

var set_clue: Clue = null

func set_clue_ui_instance(clue: Clue, index: int):
    if(clue == null):
        get_node("Name").text = "Null" + str(index);
        return;
    set_clue = clue;
    get_node("Name").text = clue.name;
    get_node("CheckBox").button_pressed = clue.automatically_unlock;
    get_node("CheckBox").toggled.connect(change_automatically_unlock);
    get_node("CheckBox2").button_pressed = clue.required_for_realization;
    get_node("CheckBox2").toggled.connect(change_required_for_realization);

func change_automatically_unlock(value: bool):
    print("automatically_unlock: " + str(value));
    set_clue.automatically_unlock = value;

func change_required_for_realization(value: bool):
    print("required_for_realization: " + str(value));
    set_clue.required_for_realization = value;
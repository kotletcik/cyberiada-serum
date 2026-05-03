extends Node

func _ready():
    EventBus.ending.connect(decide_ending);

func decide_ending():
    if(PsycheManager.instance.serum_level > PsycheManager.instance.settings.serum_overdose_level):
        UIManager.instance.start_transition_to_black(1.0, func(): EventBus.bad_ending.emit(), false);
    else:
        UIManager.instance.start_transition_to_black(1.0, func(): EventBus.good_ending.emit(), false);
extends Node

@export var shells: Array[Shell_behaviour] = [null];
@export var shell_body: Node3D
@export var lift_shell: Shell_behaviour
@export var ending_trigger: EventTrigger

func _ready() -> void:
	EventBus.final_stage.connect(reappear_shells);
	shell_body.visible = false;
	ending_trigger.enable_trigger = false;

func reappear_shells():
	shell_body.visible = true;
	lift_shell.disable();
	ending_trigger.enable_trigger = true;
	for i in range(0, shells.size()):
		shells[i].enable();

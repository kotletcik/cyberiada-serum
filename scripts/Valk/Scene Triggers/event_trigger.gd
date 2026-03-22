extends Area3D

@export var enable_trigger: bool = true;
@export var event_delay: float = 0.0;
@export var trigger_event: EventBus.triggers = EventBus.triggers.None;

func _on_body_entered(body) -> void:
	if(!enable_trigger): return;
	print(body.name);
	if(body.name == "Player"):
		await get_tree().create_timer(event_delay).timeout;
		EventBus.call_event(trigger_event);
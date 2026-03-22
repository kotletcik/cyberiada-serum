extends Area3D

@export var enable_trigger: bool = true;

func _on_body_entered(body) -> void:
    if(!enable_trigger): return;
    print(body.name);
    if(body.name == "Player"):
        print("meow");
        GameManager.instance.restart_scene();

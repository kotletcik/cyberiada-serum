extends Area3D

func _on_body_entered(body) -> void:
    if(body.name == "Player"):
        GameManager.instance.is_player_in_safe_zone = true;

func _on_body_exited(body) -> void:
    if(body.name == "Player"):
        GameManager.instance.is_player_in_safe_zone = false;



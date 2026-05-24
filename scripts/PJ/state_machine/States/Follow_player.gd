extends State
class_name Follow_player

func Update(delta: float):
	update_target_position(GameManager.instance.player.global_position);

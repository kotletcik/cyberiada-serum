extends State
class_name Follow_player

var follow_position: Vector3;
var update_player_pos: bool;

func Enter():
	super.Enter();
	update_player_pos = true;
	follow_position = GameManager.instance.player.global_position #follow_position is being changed by other scripts

func Update(delta: float):
	if(update_player_pos):
		follow_position = GameManager.instance.player.global_position;
	update_target_position(follow_position);

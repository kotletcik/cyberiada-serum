extends State
class_name Follow_player

var follow_position: Vector3;

func Enter():
	super.Enter();
	follow_position = GameManager.instance.player.global_position #follow_position is being changed by other scripts

func Update(delta: float):
	update_target_position(follow_position);

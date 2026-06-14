extends State
class_name Follow_player

var follow_position: Vector3;
var update_timer:=0.0
@export var update_time = 1
func Enter():
	super.Enter();
	follow_position = GameManager.instance.player.global_position #follow_position is being changed by other scripts

func Update(delta: float):
	if update_timer > update_time:
		#update_target_position(follow_position);
		update_target_position(GameManager.instance.player.global_position);
		update_timer = 0.0
	else: update_timer += delta

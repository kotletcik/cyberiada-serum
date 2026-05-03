extends State
class_name Attack

func Update(_delta: float):
	attack()

func attack():
	# EventBus.level_changed.emit(Game_Manager.current_level)
	state_machine.mob.velocity = Vector3(0, state_machine.mob.velocity.y, 0)
	if (PsycheManager.instance.invisibility_timer > 0): return;
	if (GameManager.instance.player.global_position - state_machine.mob.global_position).length() < 1:
		GameManager.instance.game_over();

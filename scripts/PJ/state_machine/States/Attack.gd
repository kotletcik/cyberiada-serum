extends State
class_name Attack

func Enter():
	super.Enter();
	update_target_position(state_machine.mob.global_position);
	if (PsycheManager.instance.invisibility_timer > 0): return;
	if (GameManager.instance.player.global_position - state_machine.mob.global_position).length() < state_machine.mob.attack_range:
		var player = GameManager.instance.player
		#player.camera_is_blocked = true
		player.movement_is_blocked = true
		player.look_at(state_machine.mob.global_position);
		await get_tree().create_timer(1, false).timeout
		GameManager.instance.game_over();
	

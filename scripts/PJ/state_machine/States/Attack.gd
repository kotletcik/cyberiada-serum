extends State
class_name Attack

func Update(_delta: float):
	attack()

func attack():
	# EventBus.level_changed.emit(Game_Manager.current_level)
	state_machine.mob.velocity = Vector3(0, state_machine.mob.velocity.y, 0)
	if (PsycheManager.instance.invisibility_timer > 0): return;
	if (GameManager.instance.player.global_position - state_machine.mob.global_position).length() < 1:
		var player = GameManager.instance.player
		#player.camera_is_blocked = true
		player.movement_is_blocked = true
		player.look_at(state_machine.mob.global_position);
		await get_tree().create_timer(1).timeout
		GameManager.instance.game_over();

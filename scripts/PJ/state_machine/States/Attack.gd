extends State
class_name Attack

func Update(_delta: float):
	attack()

func attack():
	# EventBus.level_changed.emit(Game_Manager.current_level)
	if (PsycheManager.instance.invisibility_timer > 0): return;
	GameManager.instance.game_over();
	

extends State
class_name Debuff

var scream_volume:= 10.0

func Update(_delta: float):
	var sound_pos = GameManager.instance.player.to_global(Vector3(0, 0, -2))
	EventBus.sound_emitted_by_player.emit(sound_pos, scream_volume)	
	state_machine.mob.queue_free()

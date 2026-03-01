extends Node

signal sound_emitted_by_player(sound_pos: Vector3, sound_volume: float)
signal game_restarted
signal level_changed(level: int)
signal shells_disappear
signal shells_appear
signal clue_gathered(clue: Clue)

class_name Save
extends Resource

var checkpoint_exists: bool = false;
var last_player_pos: Vector3 = Vector3(0,0,0);
var last_serum_level: float = 0;
var last_fog_fade_level: float = 0;
var last_invisibility_timer: float = 0;

var is_serum_taken: Dictionary[int, bool];
var is_rock_taken: Dictionary[int, bool];

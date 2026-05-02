extends Node3D
class_name DoubleDoor

var isOpened: bool = false
var isMoving: bool = false
@export var isDisposable: bool = false
@export var move_distance:= 2.0
@export var move_duration:= 0.5
@export var is_open_on_start: bool = false;
@export var first_door: Node3D
@export var second_door: Node3D
@export var unlock_if_clue_realized: Clue;
@export var is_lift_door: bool = false;
var lift_close_call_started: bool = false;
@export var lift_door_close_event: EventBus.triggers = EventBus.triggers.None;
# @export var is_final_door: bool = false;
@onready var nav_region: NavigationRegion3D = get_parent() as NavigationRegion3D
@export var is_door_locked: bool = false;

var interacted: bool = false;

var lift_call_started: bool = false;
@export var lift_start_event: EventBus.triggers = EventBus.triggers.None;
@export var lift_end_node: Node3D = null;

func _ready() -> void:
	isOpened = is_open_on_start;
	if(is_open_on_start):
		first_door.position.z = first_door.position.z + move_distance;
		second_door.position.z = second_door.position.z - move_distance


func start_lift():
	lift_call_started = true;
	EventBus.call_event(lift_start_event);
	if(lift_end_node == null): return;
	GameManager.instance.player.global_position = lift_end_node.global_position;
	GameManager.instance.player.global_rotation = lift_end_node.global_rotation;
	UIManager.instance.start_transition_to_white(5.0, Callable(), false);

func _process(delta: float) -> void:
	if(!is_lift_door): return;
	var is_player_in_front: bool = false;
	var subtracted_vector: Vector3 = first_door.global_position - GameManager.instance.player.global_position;
	var direction = subtracted_vector.normalized();
	var dot: float = -first_door.global_basis.x.dot(direction);
	var is_player_inside: bool = dot > 0.0;

	if(is_player_inside == isOpened && !isMoving && interacted):
		switch_open();

	if(is_player_inside && !isOpened && !lift_close_call_started && !isMoving):
		EventBus.call_event(lift_door_close_event);
		lift_close_call_started = true;
	if(is_player_inside && !lift_call_started):
		UIManager.instance.start_transition_to_black(5.0, start_lift, false);
		lift_call_started = true;

func player_interact():
	if(is_door_locked): return;
	if(unlock_if_clue_realized != null):
		if(!PalaceManager.instance.is_clue_realized(unlock_if_clue_realized)): return;
	
	if (isMoving): return;
	if (isDisposable && interacted): return

	interacted = true;
	switch_open()

func switch_open():
	isMoving = true;

	var first_door_start_local_pos_z = first_door.position.z
	var second_door_start_local_pos_z = second_door.position.z
	var first_door_final_local_pos_z = first_door.position.z + move_distance if !isOpened else first_door.position.z - move_distance;
	var second_door_final_local_pos_z = second_door.position.z - move_distance if !isOpened else second_door.position.z + move_distance;
	var start_time = Time.get_ticks_msec()
	
	while(abs(first_door.position.z - first_door_final_local_pos_z) > 0.01):
		var now = Time.get_ticks_msec()
		var delta = (now - start_time) / 1000.0
		var opened_bool_coeff: = 1 if !isOpened else -1;
		
		first_door.position.z = first_door_start_local_pos_z + opened_bool_coeff * move_distance * sin(0.5 * delta * (PI) / move_duration) 
		second_door.position.z = second_door_start_local_pos_z + opened_bool_coeff * -1 * move_distance * sin(0.5 * delta * (PI) / move_duration)
		await get_tree().process_frame

	first_door.position.z = first_door_final_local_pos_z
	second_door.position.z = second_door_final_local_pos_z

	isOpened = !isOpened
	isMoving = false
	if (nav_region != null):
		nav_region.bake_navigation_mesh(true)


# func close_door():
# 	if(!isOpened): return;
# 	switch_open()

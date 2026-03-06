extends CharacterBody3D
class_name PlayerController


@export var start_pos: = []
@export var move_speed = SOBER_WALK_SPEED # bazowa prędkość ruchu

#movement
@export var SOBER_WALK_SPEED = 5.0
const SUBSTANCE_WALK_SPEED = 8.0
@export var CROUCH_SPEED_MULTIPLIER = 0.5
const SENSITIVITY = 0.004
var is_Crouching: bool = false
@export var crouching_noise_volume:= 2.0 # promień słyszalności
@export var walking_noise_volume:= 4.0
var noise:= 4.0

#bobbing
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

var last_frame_mouse_pos: Vector3
var mouse_input: Vector2
var camera_base_offset: Vector3 # zapamiętany oryginalny lokalny offset kamery

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var collision_shape = $CollisionShape3D

func _ready() -> void:
	
	# if start_pos and start_pos.size() >= 1:
	# 	set_start_pos(1)
	# EventBus.connect("game_restarted", set_start_pos)
	# EventBus.connect("level_changed", set_start_pos)
	# Przechwycenie kursora myszy dla obrotu kamery
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Zachowaj oryginalną lokalną pozycję kamery aby bobbing jej nie nadpisywał
	if camera:
		camera_base_offset = camera.transform.origin

# func set_start_pos(level):
# 	var _level=level
# 	if !_level:
# 		_level = Game_Manager.current_level
# 	if _level-1 < start_pos.size() and _level-1>=0:
# 		position = start_pos[_level-1]
  


func _physics_process(delta: float) -> void:

	if(UIManager.instance.is_in_esc_menu || !UIManager.instance.is_in_game): return;
	# zmiana szybkości w przyszłości by była tutaj
	move_speed = SOBER_WALK_SPEED; 
	
	if(Input.is_action_pressed("Crouch")):
		collision_shape.scale.y = 0.5;
		#position.y -= 0.1
		move_speed *= CROUCH_SPEED_MULTIPLIER;
		noise = crouching_noise_volume
		is_Crouching = true;
	elif Input.is_action_just_released("Crouch"):
		collision_shape.scale.y = 1.0;
		#position.y += 0.6
		noise = walking_noise_volume
		is_Crouching = false;

	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()

	# Kierunek ruchu oparty o obrót głowy (yaw) zamiast obracania całego ciała
	# Docelowe zachowanie FPS: W (move_forward) zawsze porusza w kierunku patrzenia poziomo (yaw kamery), ignorujemy pitch.
	var direction := Vector3.ZERO
	if head:
		var head_basis: Basis = transform.basis
		var forward: Vector3 = -head_basis.z
		var right: Vector3 = head_basis.x
		# Input: input_dir.z dodatnie przy S, ujemne przy W; invertujemy aby W dawało +forward
		var move_vec: Vector3 = right * input_dir.x + forward * (-input_dir.z)
		move_vec.y = 0.0
		if move_vec != Vector3.ZERO:
			direction = move_vec.normalized()
	else:
		print("No head node found!!!")

	# Ustawienie prędkości poziomej z lekkim wygładzaniem gdy brak inputu
	if input_dir != Vector3.ZERO:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * 7.0)
		velocity.z = lerp(velocity.z, 0.0, delta * 7.0)
	
	# Bobbing (dodawany do bazowego offsetu zamiast nadpisywać)
	t_bob += delta * velocity.length() * float(is_on_floor())
	if camera:
		camera.transform.origin = camera_base_offset + _headbob(t_bob)

	# zastosowanie ruchu
	move_and_slide()

# func _process(delta: float) -> void:
# 	t_bob += delta * velocity.length() * float(is_on_floor())
# 	if camera:
# 		camera.transform.origin = camera_base_offset + _headbob(t_bob)

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == Key.KEY_SPACE:
			var sound_pos = to_global(Vector3(0, 0, -1))
			EventBus.sound_emitted_by_player.emit(sound_pos, noise)

func _unhandled_input(event):
	# Ruch myszy steruje obrotem
	if(UIManager.instance.is_in_esc_menu || !UIManager.instance.is_in_game): return;
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		if camera:
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			# Ograniczenie pitch aby nie przekręcić głowy
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

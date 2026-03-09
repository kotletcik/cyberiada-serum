extends Node
@export var _gravity_acc: float = 9.8
@export var _body: CharacterBody3D
func _ready() -> void:
	var _parent = get_parent()
	if _parent and _parent is CharacterBody3D:
		_body = _parent
		
func _process(delta: float) -> void:
	if _body:
		# _body.velocity.y -= _gravity_acc*delta
		_body.move_and_collide(Vector3(0, -_gravity_acc*delta, 0));

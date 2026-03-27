@tool
extends CollisionShape3D
@export_tool_button("Set Visual Scale to Collision Scale") var meow: Callable = set_visual_scale

var mesh: Node3D;

func _ready() -> void:
	# var unique_shape = shape.duplicate();
	# shape = unique_shape;
	shape.changed.connect(set_visual_scale);
	mesh = get_node("DoorVisuals");

func set_visual_scale() -> void:
	mesh.scale = shape.size;
	

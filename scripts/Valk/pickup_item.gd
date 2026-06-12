class_name PickupItem
extends StaticBody3D

@export var group_name: String;
@export var event_on_pickup: EventBus.triggers = EventBus.triggers.None;
@export var clue_on_pickup: Clue = null;
# @export var does_clue_automatically_unlock: bool = false;
var is_disabled: bool = false;

@export var material: StandardMaterial3D;
@export var csg_for_material: CSGBox3D;
@export var mesh_for_material: MeshInstance3D;

func _ready() -> void:
	add_to_group(group_name);
	if(group_name == "Serum"):
		PsycheManager.instance.register_serum(self, global_position);
	
	if(csg_for_material != null):
		material = csg_for_material.material;
	if(mesh_for_material != null):
		material = mesh_for_material.get_surface_override_material(0).duplicate();

func disable() -> void:
	visible = false;
	get_node("CollisionShape3D").disabled = true;
	is_disabled = true;

func enable() -> void:
	visible = true;
	get_node("CollisionShape3D").disabled = false;
	is_disabled = false;


func hover(): 
	material.albedo_color.a = 0.5;
	if(mesh_for_material != null):
		mesh_for_material.set_surface_override_material(0, material);

func unhover(): 
	material.albedo_color.a = 1;
	if(mesh_for_material != null):
		mesh_for_material.set_surface_override_material(0, material);

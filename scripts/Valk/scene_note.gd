extends StaticBody3D

@export var note_to_hold: Note;
@export var clue_to_gather: Clue;
@export var clue_gathered: bool = false;

# @export 
var material: StandardMaterial3D;
@export var mesh_for_material: MeshInstance3D;

func _ready() -> void:
	material = mesh_for_material.material_override.duplicate();

func player_interact() -> void:
	# print(note_to_hold.title);
	# print(note_to_hold.content);
	PalaceManager.instance.gather_note(note_to_hold);
	
	if(clue_to_gather == null || clue_gathered): return;
	PalaceManager.instance.add_gathered_clue(clue_to_gather);
	clue_gathered = true;

func hover(): 
	material.albedo_color.a = 0.5;
	mesh_for_material.material_override = material;

func unhover(): 
	material.albedo_color.a = 1;
	mesh_for_material.material_override = material;

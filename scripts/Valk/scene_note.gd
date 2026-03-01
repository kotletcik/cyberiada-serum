extends StaticBody3D

@export var note_to_hold: Note;
@export var clue_to_gather: Clue;
@export var clue_gathered: bool = false;

func player_interact() -> void:
	print(note_to_hold.title);
	print(note_to_hold.content);
	UIManager.instance.show_note_ui(note_to_hold.content);
	if(clue_to_gather == null): return;
	if(!clue_gathered): 
		PalaceManager.instance.add_gathered_clue(clue_to_gather);
		clue_gathered = true;
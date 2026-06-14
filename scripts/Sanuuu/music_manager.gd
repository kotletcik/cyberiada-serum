extends Node3D

@export var MusicController: AudioStreamPlayer
var playingChasing := false

func _ready() -> void:
	playingChasing = GameManager.instance.is_player_chased()

func _process(_delta: float) -> void:
	var isChasing := GameManager.instance.is_player_chased()
	if isChasing != playingChasing:
		playingChasing = isChasing
		switch_music()

func switch_music() -> void:
	if playingChasing:
		MusicController["parameters/switch_to_clip"] = "Chase"
		return
	MusicController["parameters/switch_to_clip"] = "Background"

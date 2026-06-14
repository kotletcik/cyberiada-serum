extends Node3D

var isChasing := false
var playingChasing := false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if isChasing != playingChasing:
		playingChasing = isChasing
		switch_music()

func switch_music() -> void:
	if playingChasing:
		$ChaseMusic.stop()
		$BackgroundMusic.play()
		return
	$BackgroundMusic.stop()
	$ChaseMusic.play()

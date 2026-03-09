extends Node

var music_player

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

func play_music(stream):
	music_player.stream = stream
	music_player.play()

func stop_music():
	music_player.stop()

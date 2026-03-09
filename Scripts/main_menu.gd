extends Node2D

func _ready():
	if !MusicManager.music_player.playing:
		MusicManager.play_music(preload("res://Assets/Music/SearchingForABody.mp3"))

func _on_start_pressed() -> void:
	$FadeTransition.show()
	$FadeTransition/Timer.start()
	$FadeTransition/AnimationPlayer.play("FadeIn")
	


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/options.tscn")



func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_timer_timeout() -> void:
	MusicManager.stop_music()
	get_tree().change_scene_to_file("res://Scenes/game_map.tscn")

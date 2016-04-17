extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#get_node("BGM").play()
	var level_bgm = get_node("/root/LevelBGM")
	var globals = get_node("/root/globals")
	if !level_bgm.is_playing():
		level_bgm.play()
	if globals.audio_muted:
		level_bgm.set_paused(true)
	pass



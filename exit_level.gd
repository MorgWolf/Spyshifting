extends Node2D

export var next_level = ""

func exit_level():
	#var s = ResourceLoader.load(next_level)
	#var next_scene = s.instance()
	#get_tree().get_root().add_child(next_scene)
	#get_tree().set_current_scene(next_scene)

	#get_tree().change_scene(next_level)

	var player = get_tree().get_nodes_in_group("Player")[0]
	if not get_node("/root/globals").audio_muted:
		get_node("/root/LevelBGM/SamplePlayer").play("level_change", true)
	if next_level == "":
		get_node("/root/LevelBGM").stop()
		next_level = "res://main_menu.scn.xml"
	player.transition_new_scene(next_level)

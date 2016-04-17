extends Node2D

export var color = "red"
export var type = "slim"

func _ready():
	set_fixed_process(true)
	var sprite = get_node("AnimatedSprite")
	if sprite.tex == null:
		sprite.tex = load("res://Artwork/sprites/" + color + "-" + type + "-spritesheet.png")
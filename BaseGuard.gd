extends Node2D

export var color = "red"
export var type = "slim"
export var direction = 0

func _ready():
	set_fixed_process(true)
	var sprite = get_node("AnimatedSprite")
	if sprite.tex == null:
		sprite.tex = load("res://Artwork/sprites/" + color + "-" + type + "-spritesheet.png")
	sprite.idle_ani(direction)
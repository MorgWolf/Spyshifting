extends KinematicBody2D

var dir = 2
var ani = false

var char_color = "mc"
var char_type = ""

func update_sprite(sprite):
	if char_type == "":
		sprite.tex = load("res://Artwork/sprites/" + char_color + "-spritesheet.png")
	else:
		sprite.tex = load("res://Artwork/sprites/" + char_color + "-" + char_type + "-spritesheet.png")

func _ready():
	self.set_process(true)
	var sprite = get_node("AnimatedSprite")
	if sprite.tex == null:
		update_sprite(sprite)
	

func _process(delta):

	# get_parent().set_pos(Vector2(-get_pos().x + 8 * 64 - 32, -get_pos().y + 6 * 64 - 32))

	var sprite = get_node("AnimatedSprite")

	var v = 64 * 1.5 # pixels per second. one tile is 16 px

	var vel = Vector2(0, 0)
	if(Input.is_key_pressed(KEY_DOWN)):
		vel.y += v
		dir = 2
		ani = true
	if(Input.is_key_pressed(KEY_UP)):
		vel.y -= v
		dir = 0
		ani = true
	if(Input.is_key_pressed(KEY_LEFT)):
		vel.x -= v
		dir = 3
		ani = true
	if(Input.is_key_pressed(KEY_RIGHT)):
		vel.x += v
		dir = 1
		ani = true
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	if Input.is_key_pressed(KEY_PAUSE):
		get_tree().set_pause(true)
	if Input.is_key_pressed(KEY_SPACE):
		get_tree().set_pause(false)

		var min_dist = 999 * 64
		var closest_guard = null
		for child in get_parent().get_children():
			if child.get_name() == "Guard":
				var guard = null
				if child.has_node("Mind"):
					guard = child.get_node("Mind")
				else:
					guard = child
				
				var dist = guard.get_global_pos().distance_to(child.get_global_pos())
				if dist < min_dist:
					min_dist = dist
					closest_guard = guard
		if closest_guard != null:
			char_color = closest_guard.char_color
			char_type = closest_guard.char_type
			update_sprite(sprite)

	if vel.x == 0 and vel.y == 0:
		ani = false

	move(vel * delta)


	if ani:
		sprite.move_ani(dir)
	else:
		sprite.idle_ani(dir)

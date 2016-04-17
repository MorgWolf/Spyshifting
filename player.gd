extends KinematicBody2D

var dir = 2
var ani = false

var color = "mc"
var type = ""

export var action_range = 0 # = 999 * 64

func update_sprite(sprite):
	if type == "":
		sprite.tex = load("res://Artwork/sprites/" + color + "-spritesheet.png")
	else:
		sprite.tex = load("res://Artwork/sprites/" + color + "-" + type + "-spritesheet.png")

func _ready():
	self.set_process(true)
	add_to_group("Player")
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
		
		var min_dist = action_range
		var closest_guard = null
		for n in get_tree().get_nodes_in_group("Enemies"):
			var dist = n.get_global_pos().distance_to(get_global_pos())
			if dist < min_dist:
				min_dist = dist
				closest_guard = n
		if closest_guard != null:
			color = closest_guard.color
			type = closest_guard.type
			update_sprite(sprite)

	if vel.x == 0 and vel.y == 0:
		ani = false

	move(vel * delta)

	if ani:
		sprite.move_ani(dir)
	else:
		sprite.idle_ani(dir)
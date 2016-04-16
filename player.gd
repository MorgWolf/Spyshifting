extends KinematicBody2D

var dir = 2
var ani = false

func _ready():
	self.set_process(true)

func _process(delta):
	var sprite = self.get_child(0)

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

	if vel.x == 0 and vel.y == 0:
		ani = false

	move(vel * delta)

	var ms_per_frame
	if ani:
		sprite.move_ani(dir)
		ms_per_frame = 100
	else:
		sprite.idle_ani(dir)
		ms_per_frame = 250
	var f = (OS.get_ticks_msec() / ms_per_frame) % sprite.get_frame_count()
	sprite.set_frame(f)

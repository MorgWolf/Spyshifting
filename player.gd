extends KinematicBody2D

export var dir = 2
var ani = false

var color = "mc"
var type = ""

var fade_to_black = false
var fade_to_black_action = ""
var fade_to_black_action_arg = ""
var ignore_input = false
var can_attack = true
var shapeshift_duration = 0 # how long are we currently into shapeshifting?
var shapeshift_max_duration = 0 # total max time we can stay in shapeshift before we go back to normal

export var attack_cooldown = 0.5 
export var action_range = 64 * 0.75  # distance for attack to succeed: 0.75 tiles
export var player_speed_tiles = 3.0  # in tiles per second

var shapeshift_from = ""

var pause_start = 0

func update_sprite(sprite):
	if type == "":
		sprite.tex = load("res://Artwork/sprites/" + color + "-spritesheet.png")
	else:
		sprite.tex = load("res://Artwork/sprites/" + color + "-" + type + "-spritesheet.png")

func _ready():
	self.set_process(true)
	get_node("AttackCooldown").set_wait_time(attack_cooldown)
	add_to_group("Player")
	var sprite = get_node("AnimatedSprite")
	if sprite.tex == null:
		update_sprite(sprite)
	var fade_to_black_panel = get_node("FadeToBlackPanel")
	fade_to_black_panel.set_hidden(false)
	fade_to_black_panel.set_opacity(1)

func _process(delta):
	var sprite = get_node("AnimatedSprite")
	var v = 64 * player_speed_tiles
	var vel = Vector2(0, 0)
	if not ignore_input:
		if(Input.is_key_pressed(KEY_DOWN)):
			vel.y += v
			dir = 3
			ani = true
		if(Input.is_key_pressed(KEY_UP)):
			vel.y -= v
			dir = 1
			ani = true
		if(Input.is_key_pressed(KEY_LEFT)):
			vel.x -= v
			dir = 2
			ani = true
		if(Input.is_key_pressed(KEY_RIGHT)):
			vel.x += v
			dir = 0
			ani = true
		if Input.is_key_pressed(KEY_ESCAPE) and OS.get_ticks_msec() - pause_start > 150:
			get_tree().set_pause(true)
			get_node("Panel").set_hidden(false)
			pause_start = OS.get_ticks_msec()
		if Input.is_key_pressed(KEY_SPACE):
			if can_attack:
				handle_attack()

	if vel.x == 0 and vel.y == 0:
		ani = false

	move(vel * delta)

	if ani:
		sprite.move_ani(dir)
	else:
		sprite.idle_ani(dir)

	var fade_to_black_panel = get_node("FadeToBlackPanel")
	if fade_to_black:
		var new_opacity = fade_to_black_panel.get_opacity() + delta
		fade_to_black_panel.set_hidden(false)
		fade_to_black_panel.set_opacity(new_opacity)
		if new_opacity > 1:
			fade_to_black = false
			if fade_to_black_action == "new_scene":
				get_tree().change_scene(fade_to_black_action_arg)
				return
	else:
		if fade_to_black_panel.is_visible():
			var new_opacity = fade_to_black_panel.get_opacity() - delta
			fade_to_black_panel.set_opacity(new_opacity)
			if new_opacity < 0:
				fade_to_black_panel.set_hidden(true)

func handle_attack():
	var sprite = get_node("AnimatedSprite")
	var min_dist = action_range
	var closest_guard = null
	can_attack = false
	get_node("AttackParticles").set_emitting(true)
	get_node("AttackParticles/Timer").start()
	get_node("AttackCooldown").start()
	if !get_node("/root/globals").audio_muted:
		get_node("/root/LevelBGM/SamplePlayer").play("shapeshift")
	for n in get_tree().get_nodes_in_group("Enemies"):
		var dist = n.get_global_pos().distance_to(get_global_pos())
		if dist < min_dist:
			min_dist = dist
			closest_guard = n
	if closest_guard != null:
		closest_guard.on_attack()
		color = closest_guard.color
		type = closest_guard.type
		shapeshift_from = closest_guard.get_name()
		shapeshift_max_duration = closest_guard.frozen_timeout
		shapeshift_duration = 0
		get_node("TextureProgress").set_value(100)
		get_node("TextureProgress").set_hidden(false)
		get_node("TextureProgress/ShapeshiftTimer").stop() # calling stop + start just to make sure there's no weird stuff
		get_node("TextureProgress/ShapeshiftTimer").start() 
		update_sprite(sprite)

func lose_power(name):
	# Drop your power if the name of the guard that we attacked is the same
	# as the latest guard we attacked (it means timer expired)
	if shapeshift_from == name:
		if !get_node("/root/globals").audio_muted:
			get_node("/root/LevelBGM/SamplePlayer").play("shapeshift_off")
		shapeshift_from = ""
		color = "mc"
		type = ""
		var sprite = get_node("AnimatedSprite")
		update_sprite(sprite)
		get_node("TextureProgress").set_hidden(true)
		get_node("TextureProgress/ShapeshiftTimer").stop()

func transition_new_scene(new_scene_name):
	for n in get_tree().get_nodes_in_group("Ephemerals"):
		n.set_hidden(true)
	fade_to_black = true
	fade_to_black_action = "new_scene"
	fade_to_black_action_arg = new_scene_name
	ignore_input = true

func _on_Attack_Emitter_Timer_timeout():
	get_node("AttackParticles").set_emitting(false)

func _on_AttackCooldown_timeout():
	can_attack = true

func _on_ShapeshiftTimer_timeout():
	shapeshift_duration += get_node("TextureProgress/ShapeshiftTimer").get_wait_time()
	var new_value = 100 - float(shapeshift_duration) / float(shapeshift_max_duration) * 100
	get_node("TextureProgress").set_value(new_value)

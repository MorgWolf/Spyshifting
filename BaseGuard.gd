extends Node2D

export var color = "red"
export var type = "slim"
export var direction = 0

export var view_range = 2
export var frozen_timeout = 15 # duration of time when we are frozen

var can_see_player = false
var is_frozen = false
var frozen_duration = 0

var _in_fixed_process = true

var colors = {"red": Color(0.8,0.2,0.2), "blue": Color(0.2,0.2,0.8), "green": Color(0.2,0.8,0.2), "yellow": Color(0.5,0.5,0.24) }

func path_a_to_b(nav2d, a, b):
	if a != null and b != null:
		var a_nav2dpos = nav2d.get_global_transform().xform(a.get_global_pos())
		var b_nav2dpos = nav2d.get_global_transform().xform(b.get_global_pos())
		var path = nav2d.get_simple_path(a_nav2dpos, b_nav2dpos)
		return path
	return null

func _ready():
	set_fixed_process(true)
	set_direction(direction)
	add_to_group("Enemies")
	add_to_group("Ephemerals")
	var sprite = get_node("AnimatedSprite")
	if sprite.tex == null:
		sprite.tex = load("res://Artwork/sprites/" + color + "-" + type + "-spritesheet.png")
	sprite.idle_ani(direction)
	sprite.set_rot(0)
	set_rot(0)
	var cone = get_node("Cone of Vision")
	cone.set_rot(direction * 3.14159/2)
	var coneSprite = cone.get_node("Sprite")
	coneSprite.set_modulate(colors[color])
	coneSprite.set_scale(Vector2(view_range/8.0, view_range/8.0))

func _fixed_process(delta):
	_in_fixed_process = true
	var player = get_tree().get_nodes_in_group("Player")[0]
	try_see_player()
	if can_see_player and player.color != color and !is_frozen:
		# Player was spotted, we restart the scene!
		player.transition_new_scene(get_tree().get_current_scene().get_filename())
	_in_fixed_process = false

func try_see_player():
	if not _in_fixed_process:
		print("ALERT! try_see_player() called outside _fixed_process.")
		return
	var sprite = get_child(0)
	var player = get_tree().get_nodes_in_group("Player")[0]

	# based on where the player is, and based on direction we're facing, can we see the player?
	var distance = player.get_global_pos().distance_to(sprite.get_global_pos())

	if distance < 0.25 * 64:
		# critical closeness. no more checks needed.
		can_see_player = true
		return

	var close_enough = distance < view_range * 64

	if close_enough:
		var angle = sprite.get_global_pos().angle_to_point(player.get_global_pos())
		angle *= 180.0 / 3.14159
		if angle < 0:
			angle += 360.0
			
		var angle_mod = 0

		if (direction == 1 and (angle > 315 - angle_mod or angle < 45 + angle_mod)) or \
		   (direction == 2 and angle > 45 - angle_mod and angle < 135 + angle_mod) or \
		   (direction == 3 and angle > 135 - angle_mod and angle < 225 + angle_mod) or \
		   (direction == 0 and angle > 225 - angle_mod and angle < 315 + angle_mod):
			var path = path_a_to_b(get_tree().get_nodes_in_group("Nav2D")[0], sprite, player)
			var n_old = sprite.get_global_pos()
			var distance = 0
			if path.size() > 2:
				can_see_player = false
			else:
				can_see_player = true
		else:
			can_see_player = false
	else: 
		can_see_player = false

func set_direction(new_dir):
	direction = new_dir
	var cone = get_child(1)
	cone.set_rot(direction * 3.14159 / 2)

func on_attack():
	is_frozen = true
	frozen_duration = 0
	get_node("FrozenTimer").start()
	get_node("AttackedParticles").set_emitting(true)
	get_node("AttackedParticles/Timer").start()

func _on_FrozenTimer_timeout():
	set_hidden(is_visible())
	var cone = get_node("Cone of Vision")
	cone.set_hidden(true)
	var timer = get_node("FrozenTimer")
	frozen_duration += timer.get_wait_time()
	
	if frozen_duration >= frozen_timeout:
		var player = get_tree().get_nodes_in_group("Player")[0]
		player.lose_power(get_name())
		set_hidden(false)
		cone.set_hidden(false)
		is_frozen = false
		timer.stop()


func _on_AttackedTimer_timeout():
	get_node("AttackedParticles").set_emitting(false)

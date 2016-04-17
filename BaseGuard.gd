extends Node2D

export var color = "red"
export var type = "slim"
export var direction = 0

export var view_range = 2

var can_see_player = false
var is_frozen = false

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
	var sprite = get_node("AnimatedSprite")
	if sprite.tex == null:
		sprite.tex = load("res://Artwork/sprites/" + color + "-" + type + "-spritesheet.png")
	sprite.idle_ani(direction)
	
func try_see_player():
	var sprite = get_child(0)
	var player = get_tree().get_nodes_in_group("Player")[0]

	# based on where the player is, and based on direction we're facing, can we see the player?
	var close_enough = player.get_global_pos().distance_to(sprite.get_global_pos()) < view_range * 2 * 64

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
			for n in path:
				distance = n_old.distance_to(n)
				n_old = n
			if distance <= view_range*64:
				can_see_player = true
			else:
				can_see_player = false
		else:
			can_see_player = false
	else: 
		can_see_player = false
		
func set_direction(new_dir):
	direction = new_dir
	var cone = get_child(1)
	cone.set_rot(direction * 3.14159 / 2)

func _fixed_process(delta):
	var player = get_tree().get_nodes_in_group("Player")[0]
	try_see_player()
	if can_see_player and player.color != color:
		print(get_name() + " can see player! GAME OVER.")
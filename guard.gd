extends PathFollow2D

func path_a_to_b(nav2d, a, b):
	if a != null and b != null:
		var a_nav2dpos = nav2d.get_global_transform().xform(a.get_global_pos())
		var b_nav2dpos = nav2d.get_global_transform().xform(b.get_global_pos())
		var path = nav2d.get_simple_path(a_nav2dpos, b_nav2dpos)
		return path
	return null
	
func _ready():
	set_fixed_process(true)

func _fixed_process(delta): 
	var nav2d = get_parent().get_parent().get_parent()
	var player = nav2d.get_node("Player")
	var sprite = get_parent().get_parent().get_child(0)

	var old_offset = get_offset()
	set_offset(get_offset() + (64 * 1.5 *delta))
	
	# we want rotation for purposes of direction calculation, but child sprite should
	# not actually be visually rotated.
	sprite.set_rot(-get_rot())

	# turn mathematical ccw rotation angle into one of four direction
	var rot = get_rot()
	var dir = rot / (3.14159*2) * 4

	dir = int(round(dir))
	if dir < 0:
		dir += 4
	dir %= 4

	# based on where the player is, and based on direction we're facing, can we see the player?
	var sees_player = false
	var close_enough = player.get_global_pos().distance_to(sprite.get_global_pos()) < 4 * 64
	if close_enough:
		var angle = sprite.get_global_pos().angle_to_point(player.get_global_pos())
		angle *= 180.0 / 3.14159
		if angle < 0:
			angle += 360.0
		var good_angle = false
		
		var angle_mod = 20
		
		if dir == 1 and (angle > 315 - angle_mod or angle < 45 + angle_mod):
			good_angle = true
		elif dir == 2 and angle > 45 - angle_mod and angle < 135 + angle_mod:
			good_angle = true
		elif dir == 3 and angle > 135 - angle_mod and angle < 225 + angle_mod:
			good_angle = true
		elif dir == 0 and angle > 225 - angle_mod and angle < 315 + angle_mod:
			good_angle = true

		if good_angle:
			var path = path_a_to_b(nav2d, sprite, player)
			if path.size() == 2:
				sees_player = true

	# files have different direction than the mathematical, ccw direction...
	# take the direction and turn it into the order inside sprite files.
	# ugh :(
	if dir == 0:  # face right
		dir = 1  # face our right
	elif dir == 1:  # face up
		dir = 0  # face our up
	elif dir == 2:  # face left
		dir = 3  # face our right
	elif dir == 3:  # face down
		dir = 2  # face our down

	# trigger move animation in stated direction
	#if not sees_player or player.color == get_parent().color:
	#	sprite.move_ani(dir % 4)
	#else:
	#	set_offset(old_offset)
	#	sprite.set_rot(-get_rot())
	#	sprite.idle_ani(dir % 4)

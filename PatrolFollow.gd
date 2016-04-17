extends PathFollow2D

export var speed = 1.5

func _ready():
	set_fixed_process(true)

func _fixed_process(delta): 
	var old_offset = get_offset()
	set_offset(get_offset() + (64 * speed *delta))
	var patrolling_guard = get_child(0)
	var sprite = patrolling_guard.get_child(0)
	var player = get_tree().get_nodes_in_group("Player")[0]
	
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

	patrolling_guard.direction = dir

	# trigger move animation in stated direction
	if not patrolling_guard.can_see_player or player.color == patrolling_guard.color:
		sprite.move_ani(patrolling_guard.direction % 4)
	else:
		set_offset(old_offset)
		sprite.set_rot(-get_rot())
		sprite.idle_ani(patrolling_guard.direction % 4)

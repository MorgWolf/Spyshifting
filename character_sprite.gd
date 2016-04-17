extends AnimatedSprite

var frame_count = 1
var tex = null
var ms_per_frame = 0


func _ready():
	set_process(true)
	
func idle_ani(dir):
	ani(tex, dir, 0, 6)
	ms_per_frame = 250

func move_ani(dir):
	ani(tex, dir, 4, 4)
	ms_per_frame = 100

func ani(tex, dir, move, framecount):
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
	
	var frs = SpriteFrames.new()
	set_sprite_frames(frs)

	frs.clear()
	for i in range(0, framecount):
		var atlas = AtlasTexture.new()
		atlas.set_atlas(tex)
		atlas.set_region(Rect2(i * 64, (dir + move) * 64, 64, 64))
		frs.add_frame(atlas)
	frame_count = framecount

func get_frame_count():
	return frame_count

func _process(delta):
	var f
	if ms_per_frame == 0:
		f = 0
	else:
		f = (OS.get_ticks_msec() / ms_per_frame) % get_frame_count()
	set_frame(f)


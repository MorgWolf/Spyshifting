extends AnimatedSprite

var frame_count = 1
var tex = null
var ms_per_frame = 0

func _init():
	tex = load("res://Artwork/sprites/mc-spritesheet.png")

func _ready():
	set_process(true)

func idle_ani(dir):
	ani(tex, dir, 0, 6)
	ms_per_frame = 250

func move_ani(dir):
	ani(tex, dir, 4, 4)
	ms_per_frame = 100

func ani(tex, dir, move, framecount):
	var frs = self.get_sprite_frames()
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


extends AnimatedSprite

var frame_count = 1
var tex = null

func _init():
	tex = load("res://Artwork/sprites/mc-spritesheet.png")

func idle_ani(dir):
	ani(tex, dir, 0, 6)

func move_ani(dir):
	ani(tex, dir, 1, 4)


func ani(tex, dir, move, framecount):
	var frs = self.get_sprite_frames()
	frs.clear()
	for i in range(0, framecount):
		var atlas = AtlasTexture.new()
		atlas.set_atlas(tex)
		atlas.set_region(Rect2(i * 64, (dir * 2 + move) * 64, 64, 64))
		frs.add_frame(atlas)
	frame_count = framecount

func get_frame_count():
	return frame_count

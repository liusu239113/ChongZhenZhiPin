extends RefCounted








const GRAIN_TEXTURE_SIZE: = 128

static func smooth_noise(t: float) -> float:
    return t * t * (3.0 - 2.0 * t)

static func hash_noise(x: int, y: int, seed: int) -> float:
    var value: = sin(float(x) * 12.9898 + float(y) * 78.233 + float(seed) * 37.719) * 43758.5453
    return value - floor(value)

static func tile_noise(x: int, y: int, cells: int, seed: int) -> float:
    var gx: = float(x) / float(GRAIN_TEXTURE_SIZE) * float(cells)
    var gy: = float(y) / float(GRAIN_TEXTURE_SIZE) * float(cells)
    var x0: = int(floor(gx)) % cells
    var y0: = int(floor(gy)) % cells
    var x1: = (x0 + 1) % cells
    var y1: = (y0 + 1) % cells
    var tx: = smooth_noise(gx - floor(gx))
    var ty: = smooth_noise(gy - floor(gy))
    var a: = hash_noise(x0, y0, seed)
    var b: = hash_noise(x1, y0, seed)
    var c: = hash_noise(x0, y1, seed)
    var d: = hash_noise(x1, y1, seed)
    return lerpf(lerpf(a, b, tx), lerpf(c, d, tx), ty)



static func build_card_noise_texture(size: int = 64) -> ImageTexture:
    var img: = Image.create(size, size, false, Image.FORMAT_RGBA8)
    for x in range(size):
        for y in range(size):
            var v: = randf()
            if v > 0.5:
                img.set_pixel(x, y, Color(0, 0, 0, randf() * 0.1))
            else:
                img.set_pixel(x, y, Color(1, 1, 1, randf() * 0.03))
    return ImageTexture.create_from_image(img)

static func build_city_panel_texture() -> ImageTexture:
    var img: = Image.create(GRAIN_TEXTURE_SIZE, GRAIN_TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
    for y in range(GRAIN_TEXTURE_SIZE):
        for x in range(GRAIN_TEXTURE_SIZE):
            var cloud: = tile_noise(x, y, 8, 7) * 0.58 + tile_noise(x, y, 18, 23) * 0.3 + tile_noise(x, y, 34, 41) * 0.12
            var grain: = hash_noise(x, y, 91)
            var dust: = hash_noise(int(floor(float(x) / 2.0)), int(floor(float(y) / 2.0)), 131)
            var col: = Color(0.66, 0.49, 0.28, 0.038 + cloud * 0.032)
            if grain < 0.035:
                col = Color(0.27, 0.17, 0.09, 0.075 + hash_noise(x, y, 151) * 0.06)
            elif grain > 0.965:
                col = Color(0.9, 0.74, 0.44, 0.04 + hash_noise(x, y, 173) * 0.045)
            if dust > 0.987:
                col = Color(0.23, 0.15, 0.08, 0.09 + hash_noise(x, y, 197) * 0.07)
            img.set_pixel(x, y, col)
    return ImageTexture.create_from_image(img)

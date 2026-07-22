extends RefCounted
class_name PortraitBacking












static func make_tone_material(fringe_strength: = 0.0) -> ShaderMaterial:
    var shader: = Shader.new()
    shader.code = "\nshader_type canvas_item;\nuniform float saturation = 1.0;\nuniform float brightness = 1.0;\nuniform float fringe_strength = 0.0;\nvoid fragment() {\n\t// 片段着色器里 COLOR 的初值即「节点 modulate × 顶点色」。先存进局部变量，\n\t// 用它替代内置 MODULATE：Compatibility(GL/Metal) 后端对 canvas_item 的 MODULATE\n\t// 支持不稳定会导致整段 shader 编译失败回退（立绘白边不再被压制）。此写法跨后端等价。\n\tvec4 node_modulate = COLOR;\n\tvec4 c = texture(TEXTURE, UV);\n\t// 白边压制：仅作用于抗锯齿产生的半透明边缘像素（0 < a < ~1）且偏白的部分，\n\t// 将其压暗并进一步降 alpha，把白色光圈转成暗边/虚化。实心人物本体 a≈1 不受影响。\n\tif (fringe_strength > 0.0 && c.a > 0.004 && c.a < 0.97) {\n\t\tfloat lum = dot(c.rgb, vec3(0.299, 0.587, 0.114));\n\t\tfloat whiteness = smoothstep(0.55, 0.95, lum);\n\t\tfloat k = whiteness * fringe_strength;\n\t\tc.rgb = mix(c.rgb, c.rgb * 0.42, k);\n\t\tc.a *= mix(1.0, 0.5, k);\n\t}\n\tfloat g = dot(c.rgb, vec3(0.299, 0.587, 0.114));\n\tvec3 desat = mix(vec3(g), c.rgb, saturation);\n\t// 乘回节点 MODULATE：占位/示意立绘通过设置深灰 modulate 压成近黑蒙版，\n\t// 不乘 MODULATE 时该 modulate 会被本着色器覆盖而失效。\n\tCOLOR = vec4(desat * brightness, c.a) * node_modulate;\n}\n"


























    var mat: = ShaderMaterial.new()
    mat.shader = shader
    mat.set_shader_parameter("fringe_strength", fringe_strength)
    return mat

static func make_silhouette_material(color: = Color(0.105, 0.1, 0.092, 1.0)) -> ShaderMaterial:
    var shader: = Shader.new()
    shader.code = "\nshader_type canvas_item;\nuniform vec4 silhouette_color : source_color = vec4(0.105, 0.100, 0.092, 1.0);\nvoid fragment() {\n\tvec4 c = texture(TEXTURE, UV);\n\tfloat mask = smoothstep(0.02, 0.16, c.a);\n\tCOLOR = vec4(silhouette_color.rgb, silhouette_color.a * mask) * COLOR;\n}\n"








    var mat: = ShaderMaterial.new()
    mat.shader = shader
    mat.set_shader_parameter("silhouette_color", color)
    return mat




static func make_right_backing() -> TextureRect:
    var rect: = TextureRect.new()
    rect.name = "PortraitRightBacking"
    rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    rect.stretch_mode = TextureRect.STRETCH_SCALE

    var grad: = Gradient.new()
    grad.set_color(0, Color(0.8, 0.78, 0.72, 0.0))
    grad.set_color(1, Color(0.83, 0.81, 0.75, 0.92))
    grad.add_point(0.55, Color(0.81, 0.79, 0.73, 0.32))

    var tex: = GradientTexture2D.new()
    tex.gradient = grad
    tex.fill_from = Vector2(0.0, 0.5)
    tex.fill_to = Vector2(1.0, 0.5)
    tex.width = 256
    tex.height = 16
    rect.texture = tex
    return rect

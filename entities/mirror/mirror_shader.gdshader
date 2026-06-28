shader_type spatial;
render_mode unshaded;

uniform sampler2D viewport_texture : source_color, filter_linear_mipmap;

void vertex() {
	UV.x = 1.0 - UV.x; // flip horizontally
}

void fragment() {
	vec4 mirror = 1.0 - texture(viewport_texture, UV);
	ALBEDO = mirror.rgb;
	ALPHA = mirror.a;
}


shader_type spatial;
render_mode unshaded;

uniform sampler2D tile_mask_texture: source_color;
uniform float tile_size = 1.0;
uniform vec2 offset = vec2(0.0);

void fragment() {
	vec4 world = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	vec3 pos = world.xyz;
	float half = tile_size * 0.5;
	
	pos /= tile_size;
	
	ALBEDO = 1.0 - texture(tile_mask_texture, fract(pos.xz + 0.5 + offset)).rgb;
}

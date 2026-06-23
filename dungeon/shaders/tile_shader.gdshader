
shader_type spatial;
render_mode unshaded;

uniform sampler2D tile_mask_texture: source_color;
uniform vec2 scale = vec2(1.0);
// uniform vec3 edge_color: source_color = vec3(0.0);
// uniform vec3 tile_color: source_color = vec3(1.0);

void fragment() {
	// float tile_mask = texture(tile_mask_texture, fract(UV * scale)).r;
	// ALBEDO = mix(edge_color, tile_color, tile_mask);
	ALBEDO = texture(tile_mask_texture, fract(UV * scale)).rgb;
}

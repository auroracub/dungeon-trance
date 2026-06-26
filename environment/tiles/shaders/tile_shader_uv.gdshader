
shader_type spatial;
render_mode unshaded;

uniform sampler2D tile_mask_texture: source_color;
uniform float tile_size = 1.0;
uniform vec2 offset = vec2(0.0);

void fragment() {
	ALBEDO = texture(tile_mask_texture, fract(UV * tile_size + offset)).rgb;
}

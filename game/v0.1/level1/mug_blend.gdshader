shader_type canvas_item;

// Two textures to blend between
uniform sampler2D texture_a : hint_default_white;
uniform sampler2D texture_b : hint_default_white;

// Blend factor: 0.0 = fully texture_a, 1.0 = fully texture_b
uniform float blend_factor : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	// Sample both textures
	vec4 color_a = texture(texture_a, UV);
	vec4 color_b = texture(texture_b, UV);

	// Blend between them
	COLOR = mix(color_a, color_b, blend_factor);
}

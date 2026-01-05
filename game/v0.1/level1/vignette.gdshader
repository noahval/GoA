shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 vignette_color : source_color = vec4(0.8, 0.1, 0.1, 1.0);
uniform float inner_radius : hint_range(0.0, 1.0) = 0.3;
uniform float outer_radius : hint_range(0.0, 1.0) = 0.8;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv) * 2.0;  // Distance from center (0 at center, 1+ at corners)
	float vignette = smoothstep(inner_radius, outer_radius, dist);
	COLOR = vec4(vignette_color.rgb, vignette * intensity);
}

shader_type canvas_item;

uniform float speed = 0.02;
uniform float scale = 120.0;
uniform vec4 bg_color : source_color = vec4(0.02, 0.02, 0.06, 1.0);
uniform vec4 star_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float star_threshold = 0.995;
uniform float star_brightness = 0.8;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
	vec2 uv = UV * max(scale, 1.0);
	vec2 cell = floor(uv);
	vec2 local = fract(uv) - vec2(0.5);
	float twinkle = 0.55 + 0.45 * sin(TIME * 2.2 + hash(cell) * 6.28318);
	float star_seed = hash(cell + floor(TIME * speed));
	float star = step(star_threshold, star_seed);
	float shape = smoothstep(0.08, 0.0, length(local));
	vec3 color = bg_color.rgb + star_color.rgb * star * shape * twinkle * star_brightness;
	COLOR = vec4(color, bg_color.a);
}

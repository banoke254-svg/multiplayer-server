shader_type spatial;

render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec4 color_a : source_color = vec4(1.0, 0.6, 0.1, 1.0);
uniform vec4 color_b : source_color = vec4(1.0, 0.1, 0.0, 1.0);
uniform vec4 color_c : source_color = vec4(0.3, 0.02, 0.0, 1.0);
uniform vec4 accent_color : source_color = vec4(1.0, 0.92, 0.6, 1.0);
uniform vec4 emission_color : source_color = vec4(1.0, 0.42, 0.06, 1.0);
uniform float emission_strength : hint_range(0.0, 12.0) = 0.0;
uniform float speed : hint_range(0.1, 4.0) = 1.0;
uniform float alpha_strength : hint_range(0.0, 1.0) = 0.92;

void fragment() {
	vec2 uv = UV;
	float flicker = sin(TIME * 6.0 * speed + uv.y * 12.0) * 0.5 + 0.5;
	vec3 color = mix(color_a.rgb, color_b.rgb, flicker);
	color = mix(color, color_c.rgb, smoothstep(0.55, 1.0, uv.y) * 0.2);
	color = mix(color, accent_color.rgb, smoothstep(0.0, 0.28, 1.0 - uv.y) * 0.16);
	ALBEDO = color;
	ROUGHNESS = 0.14;
	SPECULAR = 0.78;
	EMISSION = vec3(0.0);
	ALPHA = alpha_strength;
}

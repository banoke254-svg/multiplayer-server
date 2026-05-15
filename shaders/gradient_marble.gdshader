shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 color_a : source_color = vec4(0.15, 0.2, 1.0, 1.0);
uniform vec4 color_b : source_color = vec4(0.95, 0.2, 0.25, 1.0);
uniform float alpha_strength : hint_range(0.0, 1.0) = 0.92;
uniform float gradient_bias : hint_range(-0.5, 0.5) = 0.0;
uniform float roughness_hint : hint_range(0.02, 1.0) = 0.08;

void fragment() {
	float t = clamp(UV.y + gradient_bias, 0.0, 1.0);
	ALBEDO = vec3(t, 0.2, 1.0 - t);
	ROUGHNESS = roughness_hint;
	METALLIC = 0.0;
	SPECULAR = 0.82;
	ALPHA = alpha_strength;
}

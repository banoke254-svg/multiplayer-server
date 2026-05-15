shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 color_a : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color_b : source_color = vec4(0.08, 0.08, 0.08, 1.0);
uniform float alpha_strength : hint_range(0.0, 1.0) = 0.92;
uniform float stripe_scale : hint_range(2.0, 40.0) = 30.0;
uniform float roughness_hint : hint_range(0.02, 1.0) = 0.08;

void fragment() {
	float stripes = step(0.0, sin(UV.x * stripe_scale));
	ALBEDO = mix(color_b.rgb, color_a.rgb, stripes);
	ROUGHNESS = roughness_hint;
	METALLIC = 0.0;
	SPECULAR = 0.82;
	ALPHA = alpha_strength;
}

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 color_a : source_color = vec4(0.72, 0.9, 1.0, 0.92);
uniform vec4 color_b : source_color = vec4(0.28, 0.62, 0.96, 1.0);
uniform vec4 color_c : source_color = vec4(0.12, 0.2, 0.52, 1.0);
uniform vec4 accent_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 emission_color : source_color = vec4(0.32, 0.72, 1.0, 1.0);
uniform float emission_strength : hint_range(0.0, 1.4) = 0.0;
uniform float alpha_strength : hint_range(0.0, 1.0) = 0.92;
uniform float gloss_strength : hint_range(0.0, 1.0) = 0.18;
uniform float roughness_hint : hint_range(0.02, 1.0) = 0.08;

void fragment() {
	float gradient = clamp(UV.y * 0.85 + 0.08, 0.0, 1.0);
	vec3 color = mix(color_a.rgb, color_b.rgb, gradient);
	color = mix(color, color_c.rgb, smoothstep(0.58, 1.0, UV.y));
	float fresnel = pow(1.0 - max(dot(normalize(NORMAL), normalize(VIEW)), 0.0), 2.4);
	color = mix(color, accent_color.rgb, fresnel * gloss_strength);
	ALBEDO = color;
	ROUGHNESS = roughness_hint;
	METALLIC = 0.0;
	SPECULAR = 0.82;
	EMISSION = emission_color.rgb * emission_strength;
	ALPHA = alpha_strength;
}

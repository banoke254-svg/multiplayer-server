shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 color_a : source_color = vec4(0.22, 0.88, 1.0, 1.0);
uniform vec4 color_b : source_color = vec4(0.84, 0.26, 1.0, 1.0);
uniform vec4 color_c : source_color = vec4(1.0, 0.98, 1.0, 1.0);
uniform vec4 accent_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 emission_color : source_color = vec4(0.62, 0.86, 1.0, 1.0);
uniform float emission_strength : hint_range(0.0, 1.4) = 0.0;
uniform float glow_strength : hint_range(0.0, 1.0) = 0.0;
uniform float rim_strength : hint_range(0.0, 1.0) = 0.0;
uniform float alpha_strength : hint_range(0.0, 1.0) = 0.9;
uniform float roughness_hint : hint_range(0.02, 1.0) = 0.06;

void fragment() {
	float gradient = clamp(UV.y + sin(UV.x * 7.0) * 0.05, 0.0, 1.0);
	vec3 color = mix(color_a.rgb, color_b.rgb, gradient);
	color = mix(color, color_c.rgb, smoothstep(0.62, 1.0, gradient));
	float fresnel = pow(1.0 - max(dot(normalize(NORMAL), normalize(VIEW)), 0.0), 2.0);
	vec3 rim = emission_color.rgb * fresnel * rim_strength;
	ALBEDO = mix(color, accent_color.rgb, fresnel * 0.22);
	ROUGHNESS = roughness_hint;
	METALLIC = 0.0;
	SPECULAR = 0.86;
	EMISSION = emission_color.rgb * emission_strength + rim * glow_strength;
	ALPHA = alpha_strength;
}

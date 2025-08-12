shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform float wave_speed : hint_range(0.1, 5.0) = 1.0;
uniform float wave_frequency : hint_range(1.0, 20.0) = 4.0;
uniform float wave_amplitude : hint_range(0.0, 1.0) = 0.5;
uniform vec3 wave_direction = vec3(1.0, 0.0, 1.0);
uniform vec3 color_a : source_color = vec3(0.1, 0.3, 0.8);
uniform vec3 color_b : source_color = vec3(0.9, 0.9, 1.0);
uniform float triplanar_sharpness : hint_range(1.0, 16.0) = 8.0;
uniform bool use_triplanar = true;

varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

// Create flowing wave patterns
float createWaves(vec3 pos, float time) {
	vec3 dir = normalize(wave_direction);
	float wave_pos = dot(pos, dir) * wave_frequency;

	// Primary wave
	float wave1 = sin(wave_pos + time * wave_speed) * wave_amplitude;

	// Secondary wave (different frequency and direction)
	float wave2 = sin(wave_pos * 1.3 - time * wave_speed * 0.7) * wave_amplitude * 0.6;

	// Perpendicular wave for more complexity
	vec3 perp_dir = normalize(cross(dir, vec3(0, 1, 0)));
	float perp_wave = sin(dot(pos, perp_dir) * wave_frequency * 0.5 + time * wave_speed * 0.5) * wave_amplitude * 0.3;

	return (wave1 + wave2 + perp_wave) * 0.5 + 0.5;
}

// Triplanar sampling for seamless mapping
float sampleWaves(vec3 pos, float time) {
	// Sample on X plane (YZ coordinates)
	float pattern_x = createWaves(vec3(0, pos.y, pos.z), time);

	// Sample on Y plane (XZ coordinates)
	float pattern_y = createWaves(vec3(pos.x, 0, pos.z), time);

	// Sample on Z plane (XY coordinates)
	float pattern_z = createWaves(vec3(pos.x, pos.y, 0), time);

	// Calculate blend weights based on surface normal
	vec3 blend_weights = abs(world_normal);
	blend_weights = pow(blend_weights, vec3(triplanar_sharpness));
	blend_weights /= (blend_weights.x + blend_weights.y + blend_weights.z);

	// Blend the three projections
	return pattern_x * blend_weights.x + pattern_y * blend_weights.y + pattern_z * blend_weights.z;
}

void fragment() {
	float time = TIME;
	vec3 final_color;

	if (use_triplanar) {
		// Triplanar wave sampling
		float wave_value = sampleWaves(world_position, time);
		final_color = mix(color_a, color_b, wave_value);

	} else {
		// Regular UV mapping fallback
		float wave_value = createWaves(vec3(UV.x, UV.y, 0.0), time);
		final_color = mix(color_a, color_b, wave_value);
	}

	ALBEDO = final_color;
	METALLIC = 0.1;
	ROUGHNESS = 0.8;

	// Subtle emission
	EMISSION = final_color * 0.1;
}

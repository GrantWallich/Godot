shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform float wave_speed : hint_range(0.1, 5.0) = 1.0;
uniform float wave_scale : hint_range(0.1, 10.0) = 2.0;
uniform float noise_scale : hint_range(0.1, 20.0) = 5.0;
uniform vec3 color_a : source_color = vec3(0.2, 0.6, 1.0);
uniform vec3 color_b : source_color = vec3(0.8, 0.2, 0.4);
uniform float triplanar_sharpness : hint_range(1.0, 16.0) = 8.0;
uniform bool use_triplanar = true;

varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

float noise(vec2 pos) {
	return fract(sin(dot(pos, vec2(12.9898, 78.233))) * 43758.5453);
}

float smoothNoise(vec2 pos) {
	vec2 i = floor(pos);
	vec2 f = fract(pos);
	f = f * f * (3.0 - 2.0 * f);
	
	float a = noise(i);
	float b = noise(i + vec2(1.0, 0.0));
	float c = noise(i + vec2(0.0, 1.0));
	float d = noise(i + vec2(1.0, 1.0));
	
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Function to sample pattern with triplanar mapping
float samplePattern(vec3 pos, float time, float scale) {
	// Sample on X plane (YZ coordinates)
	vec2 uv_x = pos.yz * scale + vec2(time * 0.3, time * 0.2);
	float wave1_x = sin(uv_x.x * 6.28) * 0.5 + 0.5;
	float wave2_x = cos(uv_x.y * 6.28 + time) * 0.5 + 0.5;
	float pattern_x = wave1_x * wave2_x;
	
	// Sample on Y plane (XZ coordinates)
	vec2 uv_y = pos.xz * scale + vec2(time * 0.2, time * 0.3);
	float wave1_y = sin(uv_y.x * 6.28) * 0.5 + 0.5;
	float wave2_y = cos(uv_y.y * 6.28 + time) * 0.5 + 0.5;
	float pattern_y = wave1_y * wave2_y;
	
	// Sample on Z plane (XY coordinates)  
	vec2 uv_z = pos.xy * scale + vec2(time * 0.4, time * 0.1);
	float wave1_z = sin(uv_z.x * 6.28) * 0.5 + 0.5;
	float wave2_z = cos(uv_z.y * 6.28 + time) * 0.5 + 0.5;
	float pattern_z = wave1_z * wave2_z;
	
	// Calculate blend weights based on surface normal
	vec3 blend_weights = abs(world_normal);
	blend_weights = pow(blend_weights, vec3(triplanar_sharpness));
	blend_weights /= (blend_weights.x + blend_weights.y + blend_weights.z);
	
	// Blend the three projections
	return pattern_x * blend_weights.x + pattern_y * blend_weights.y + pattern_z * blend_weights.z;
}

void fragment() {
	float time = TIME * wave_speed;
	vec3 final_color;
	
	if (use_triplanar) {
		// Triplanar sampling for seamless mapping
		float wave_pattern = samplePattern(world_position, time, wave_scale);
		float noise_pattern = samplePattern(world_position, time * 0.5, noise_scale);
		
		// Combine patterns
		float final_value = (wave_pattern + noise_pattern * 0.5) * 0.7;
		final_color = mix(color_a, color_b, final_value);
		
	} else {
		// Regular UV mapping (fallback)
		vec2 uv = UV;
		vec2 wave_uv = uv * wave_scale + vec2(time * 0.3, time * 0.2);
		float wave1 = sin(wave_uv.x * 6.28) * 0.5 + 0.5;
		float wave2 = cos(wave_uv.y * 6.28 + time) * 0.5 + 0.5;
		
		vec2 noise_uv = uv * noise_scale + vec2(time * 0.1, time * 0.15);
		float noise_val = smoothNoise(noise_uv);
		
		float final_value = (wave1 * wave2 + noise_val) * 0.5;
		final_color = mix(color_a, color_b, final_value);
	}
	
	ALBEDO = final_color;
	METALLIC = 0.2;
	ROUGHNESS = 0.6;
	
	// Add some emission for glow
	EMISSION = final_color * 0.3;
}

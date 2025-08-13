shader_type spatial;
render_mode unshaded, cull_front, blend_mix, fog_disabled;

uniform sampler2D noise_tex : repeat_enable, filter_linear;
uniform vec4 cloud_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float alpha : hint_range(0.0, 1.0) = 0.4;
uniform float threshold : hint_range(0.0, 1.0) = 0.5;
uniform float softness : hint_range(0.0, 1.0) = 0.2;
uniform float scale1 = 1.2;
uniform float scale2 = 2.3;
uniform float speed1 = 0.02;
uniform float speed2 = -0.015;

varying vec3 v_world_normal;
varying vec3 v_world_pos;

void vertex() {
    v_world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    v_world_pos    = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float tri_noise(vec3 p, float s){
    vec3 n = abs(normalize(v_world_normal));
    vec3 w = n / (n.x + n.y + n.z);
    float nx = texture(noise_tex, fract(p.zy * s)).r;
    float ny = texture(noise_tex, fract(p.xz * s)).r;
    float nz = texture(noise_tex, fract(p.xy * s)).r;
    return nx*w.x + ny*w.y + nz*w.z;
}

void fragment(){
    vec3 p = v_world_pos + vec3(TIME * speed1, 0.0, TIME * speed2);
    float n = 0.5 * tri_noise(p, scale1) + 0.5 * tri_noise(p, scale2);
    float mask = smoothstep(threshold - softness, threshold + softness, n);
    ALBEDO = cloud_color.rgb;
    ALPHA = mask * alpha;
}
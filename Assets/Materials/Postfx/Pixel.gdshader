shader_type canvas_item;
render_mode blend_mix;

uniform float pixels = 240.0; // target vertical resolution
uniform float mix_amount : hint_range(0.0, 1.0, 0.01) = 1.0; // 1 = fully pixelated
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest, repeat_disable;

void fragment() {
    vec2 tex_size = vec2(textureSize(SCREEN_TEXTURE, 0));
    float scale = max(1.0, floor(tex_size.y / max(pixels, 1.0)));
    vec2 uv_pix = floor(SCREEN_UV * tex_size / scale) * scale / tex_size;

    vec3 src = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
    vec3 pix = texture(SCREEN_TEXTURE, uv_pix).rgb;
    COLOR = vec4(mix(src, pix, mix_amount), 1.0);
}
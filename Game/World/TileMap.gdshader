shader_type canvas_item;

uniform float darkness = 0.3;
uniform vec4 curse_tint = vec4(0.1, 0.4, 0.0, 1.0);
uniform float tint_intensity = 0.3;
uniform float pulse_speed = 2.0;
uniform float flicker_intensity = 0.03;
uniform float wobble_strength = 0.002;

void fragment() {
    vec2 uv = UV;

    // Apply wavy distortion (cursed pulse)
    uv.y += sin(uv.x * 60.0 + TIME * pulse_speed) * wobble_strength;
    uv.x += cos(uv.y * 60.0 + TIME * pulse_speed) * wobble_strength;

    vec4 tex_color = texture(TEXTURE, uv);

    // Cursed green glow
    tex_color.rgb = mix(tex_color.rgb, curse_tint.rgb, tint_intensity);

    // Subtle darkness
    tex_color.rgb *= 1.0 - darkness;

    // Flickering corruption
    float noise = fract(sin(dot(uv * TIME, vec2(23.15, 91.38))) * 43758.5453);
    tex_color.rgb += (noise - 0.5) * flicker_intensity;

    COLOR = tex_color;
}

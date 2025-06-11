shader_type canvas_item;

uniform float darkness = 0.4;              // Balanced darkening
uniform float desaturation = 0.5;          // Makes color less vibrant
uniform vec4 curse_tint = vec4(0.1, 0.2, 0.0, 1.0); // Subtle green overlay
uniform float noise_strength = 0.03;       // Low flicker
uniform float vignette_strength = 1.4;     // Controls how fast it darkens at edges
uniform float vignette_softness = 0.5;     // Smooth falloff
uniform float pulse_speed = 1.2;           // Light breathing effect

void fragment() {
    vec2 uv = UV;
    vec4 tex_color = texture(TEXTURE, uv);

    // Step 1: Desaturate
    float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    tex_color.rgb = mix(vec3(gray), tex_color.rgb, desaturation);

    // Step 2: Darken + Curse tint
    tex_color.rgb *= 1.0 - darkness;
    tex_color.rgb += curse_tint.rgb * 0.2; // reduced from 0.4

    // Step 3: Subtle noise flicker
    float noise = fract(sin(dot(uv * TIME, vec2(12.9898,78.233))) * 43758.5453);
    tex_color.rgb += (noise - 0.5) * noise_strength;

    // Step 4: Breathing light effect
    float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);
    tex_color.rgb *= mix(0.98, 1.02, pulse);

    // Step 5: Vignette effect (balanced)
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);
    float vignette = smoothstep(vignette_strength, vignette_softness, dist);
    tex_color.rgb *= 1.0 - vignette * 0.35;

    COLOR = tex_color;
}

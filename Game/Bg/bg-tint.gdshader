shader_type canvas_item;

uniform vec4 tint_color = vec4(0.9, 0.7, 0.8, 1.0); // Soft pink for romance
uniform float tint_speed = 0.3; // Speed of tint shift
uniform float tint_strength = 0.4; // Intensity of tint

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float tint_factor = (sin(TIME * tint_speed) * 0.5 + 0.5) * tint_strength;
    COLOR = mix(color, tint_color, tint_factor * color.a);
}
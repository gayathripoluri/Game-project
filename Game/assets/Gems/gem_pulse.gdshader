shader_type canvas_item;

uniform float pulse_speed = 2.0; // Speed of pulsing
uniform float pulse_strength = 0.4; // Intensity of pulse
uniform vec4 pulse_color = vec4(0.8, 0.4, 0.8, 1.0); // Romantic magenta

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5) * pulse_strength + 1.0;
    vec3 pulsed_color = mix(color.rgb, pulse_color.rgb, pulse_strength);
    COLOR = vec4(pulsed_color * pulse, color.a);
}
shader_type canvas_item;

uniform vec4 color_a : source_color = vec4(0.05, 0.18, 0.35, 1.0);
uniform vec4 color_b : source_color = vec4(0.01, 0.07, 0.15, 1.0);

// The colour of the light catching the ripples — pale aqua by default
uniform vec4 shimmer_color : source_color = vec4(0.4, 0.85, 0.95, 1.0);
uniform float shimmer_strength : hint_range(0.0, 1.0) = 0.08;

uniform float time : hint_range(0.0, 1000.0) = 0.0;

void fragment() {
    // Vertical depth gradient
    vec4 base = mix(color_a, color_b, UV.y);

    // Two overlapping sine waves for a more organic ripple pattern
    float ripple = sin(UV.x * 8.0 + time * 0.4) * sin(UV.y * 5.0 + time * 0.3);
    ripple += sin(UV.x * 13.0 - time * 0.6) * sin(UV.y * 3.0 + time * 0.2) * 0.5;
    ripple = ripple * 0.5 + 0.5;  // remap from -1..1 to 0..1

    // Blend the shimmer colour into the base by the ripple amount
    COLOR = mix(base, shimmer_color, ripple * shimmer_strength);
}

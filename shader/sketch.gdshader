shader_type canvas_item;

uniform float sample_scale = 1.0	;
uniform float edge_strength = 1.0;
uniform float threshold = 0.1;
uniform vec2 texel_size;

void fragment() {
    vec2 texel = texel_size * sample_scale;

    float tl = dot(texture(TEXTURE, UV + texel * vec2(-1,-1)).rgb, vec3(0.299,0.587,0.114));
    float tr = dot(texture(TEXTURE, UV + texel * vec2( 1,-1)).rgb, vec3(0.299,0.587,0.114));
    float bl = dot(texture(TEXTURE, UV + texel * vec2(-1, 1)).rgb, vec3(0.299,0.587,0.114));
    float br = dot(texture(TEXTURE, UV + texel * vec2( 1, 1)).rgb, vec3(0.299,0.587,0.114));

    float l = dot(texture(TEXTURE, UV + texel * vec2(-1, 0)).rgb, vec3(0.299,0.587,0.114));
    float r = dot(texture(TEXTURE, UV + texel * vec2( 1, 0)).rgb, vec3(0.299,0.587,0.114));
    float t = dot(texture(TEXTURE, UV + texel * vec2( 0,-1)).rgb, vec3(0.299,0.587,0.114));
    float b = dot(texture(TEXTURE, UV + texel * vec2( 0, 1)).rgb, vec3(0.299,0.587,0.114));

    float gx = -tl - 2.0*l - bl + tr + 2.0*r + br;
    float gy = -tl - 2.0*t - tr + bl + 2.0*b + br;

    float edge = length(vec2(gx, gy)) * edge_strength;

    float line = step(threshold, edge);

    COLOR = vec4(vec3(1.0 - line), 1.0);
}
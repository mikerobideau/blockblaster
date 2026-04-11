shader_type canvas_item;

uniform float sample_scale = 2.0;
uniform float edge_strength = 3.0;
uniform float threshold = 0.15;

uniform float reveal_progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 texel = (1.0 / vec2(textureSize(TEXTURE, 0))) * sample_scale;

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

    float ink = step(threshold, edge); // 1 = line, 0 = background

    float mask = step(UV.y, reveal_progress);

    ink *= mask;

    // IMPORTANT: paper is always white, ink subtracts from it
    float paper = 1.0 - ink;

    COLOR = vec4(vec3(paper), 1.0);
}
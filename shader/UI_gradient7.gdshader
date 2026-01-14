shader_type canvas_item;

// These will be populated by the script
uniform vec4 bg_inner : source_color;
uniform vec4 bg_outer : source_color;
uniform vec4 border_top : source_color;
uniform vec4 border_bottom : source_color;
uniform vec4 corner_radius; // x:TL, y:TR, z:BR, w:BL
uniform float border_width;
uniform vec2 size;

float sdRoundedBox(vec2 p, vec2 b, vec4 r) {
    r.xy = (p.x > 0.0) ? r.yz : r.xw;
    r.x  = (p.y > 0.0) ? r.y  : r.x;
    vec2 q = abs(p) - b + r.x;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r.x;
}

void fragment() {
    vec2 p = (UV - 0.5) * size;
    float d = sdRoundedBox(p, size * 0.5, corner_radius);
    
    // Segmentation Masks
    float shape_mask = smoothstep(1.0, 0.0, d);
    float border_mask = smoothstep(-border_width - 1.0, -border_width, d) - smoothstep(-1.0, 0.0, d);
    
    // Background (Center-out)
    vec4 bg_color = mix(bg_inner, bg_outer, smoothstep(0.0, 0.7, distance(UV, vec2(0.5))));
    
    // Border (Top-down)
    vec4 border_col = mix(border_top, border_bottom, UV.y);
    
    vec4 final_color = mix(bg_color, border_col, border_mask);
    final_color.a *= shape_mask;
    COLOR = final_color;
}
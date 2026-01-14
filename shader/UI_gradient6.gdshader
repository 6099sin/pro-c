shader_type canvas_item;

// Background Colors (Center-out Linear)
uniform vec4 bg_inner_color : source_color = vec4(0.2, 0.4, 0.8, 1.0);
uniform vec4 bg_outer_color : source_color = vec4(0.05, 0.05, 0.2, 1.0);

// Border Colors (Top-down Linear)
uniform vec4 border_top_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 border_bottom_color : source_color = vec4(0.4, 0.4, 0.4, 1.0);

// Corner Radii (x: Top-Left, y: Top-Right, z: Bottom-Right, w: Bottom-Left)
uniform vec4 corner_radius = vec4(20.0, 20.0, 20.0, 20.0);
uniform float border_width : hint_range(0.0, 50.0) = 5.0;
uniform float gradient_softness : hint_range(0.0, 1.0) = 0.5;

// Helper function to calculate SDF of a rounded rectangle
float sdRoundedBox(vec2 p, vec2 b, vec4 r) {
    r.xy = (p.x > 0.0) ? r.yz : r.xw;
    r.x  = (p.y > 0.0) ? r.y  : r.x;
    vec2 q = abs(p) - b + r.x;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r.x;
}

void fragment() {
    // Get pixel-space coordinates for accurate rounding
    vec2 size = 1.0 / SCREEN_PIXEL_SIZE; // Using SCREEN_PIXEL_SIZE or custom uniform
    // Note: In Godot 4.x, for a more reliable size, pass a 'uniform vec2 size' 
    // and set it via script to the node's rect_size.
    
    vec2 center = vec2(0.5);
    vec2 p = (UV - center) * size;
    vec2 half_size = size * 0.5;
    
    // 1. Calculate the SDF distance
    float d = sdRoundedBox(p, half_size, corner_radius);
    
    // 2. Background Logic (Center-out)
    float dist_from_center = distance(UV, center);
    float bg_mix = smoothstep(0.0, gradient_softness, dist_from_center);
    vec4 bg_color = mix(bg_inner_color, bg_outer_color, bg_mix);
    
    // 3. Border Gradient (Top-down)
    vec4 border_color = mix(border_top_color, border_bottom_color, UV.y);
    
    // 4. Composition using AA (Anti-aliasing)
    float border_mask = smoothstep(0.0, 1.0, d + border_width);
    float shape_mask = smoothstep(1.0, 0.0, d);
    
    // Start with background, mix border based on distance, then clip the outside
    vec4 final_color = mix(border_color, bg_color, border_mask);
    final_color.a *= shape_mask;
    
    COLOR = final_color;
}
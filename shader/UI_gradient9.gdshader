shader_type canvas_item;

// --- Colors ---
uniform vec4 color_top : source_color = vec4(1.0, 0.85, 0.7, 1.0);    // Peach/Cream top
uniform vec4 color_bottom : source_color = vec4(1.0, 0.45, 0.2, 1.0); // Deep Orange bottom
uniform vec4 highlight_center : source_color = vec4(1.0, 1.0, 0.9, 0.4); // Subtle center glow
uniform vec4 border_color : source_color = vec4(0.9, 0.8, 0.4, 1.0);   // Metallic Gold border

// --- Parameters ---
uniform float border_width : hint_range(0.0, 0.1) = 0.02;
uniform float corner_radius : hint_range(0.0, 0.5) = 0.2;
uniform float horizontal_spread : hint_range(0.1, 2.0) = 1.0; // Controls the "center-out" width

// SDF function for rounded corners
float sd_rounded_rect(vec2 uv, vec2 size, float radius) {
    vec2 d = abs(uv - 0.5) - (size * 0.5) + radius;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - radius;
}

void fragment() {
    vec2 uv = UV;
    
    // 1. Shape and Masking
    float dist = sd_rounded_rect(uv, vec2(1.0), corner_radius);
    float body_mask = smoothstep(0.01, 0.0, dist);
    float border_mask = smoothstep(0.0, 0.01, dist + border_width) * body_mask;
    
    // 2. Vertical Base Gradient (Top to Bottom)
    vec4 base_color = mix(color_bottom, color_top, uv.y);
    
    // 3. Center-Out Horizontal Gradient (Highlight)
    // We calculate distance from the vertical center line (x = 0.5)
    float center_dist = abs(uv.x - 0.5) * 2.0;
    float horizontal_highlight = smoothstep(horizontal_spread, 0.0, center_dist);
    
    // 4. Combine Gradients
    // Adds the center highlight on top of the vertical base
    vec3 mixed_bg = mix(base_color.rgb, highlight_center.rgb, horizontal_highlight * highlight_center.a);
    
    // 5. Final Composition with Gold Border
    vec3 final_rgb = mix(mixed_bg, border_color.rgb, border_mask);
    
    COLOR = vec4(final_rgb, body_mask);
}
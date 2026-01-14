shader_type canvas_item;

// --- Body Colors ---
uniform vec4 body_top : source_color = vec4(1.0, 0.85, 0.7, 1.0);
uniform vec4 body_bottom : source_color = vec4(1.0, 0.45, 0.2, 1.0);
uniform vec4 body_center : source_color = vec4(1.0, 1.0, 0.9, 1.0);

// --- Border Colors ---
uniform vec4 border_top : source_color = vec4(0.95, 0.85, 0.5, 1.0); // Bright Gold
uniform vec4 border_bottom : source_color = vec4(0.6, 0.4, 0.1, 1.0); // Bronze/Dark Gold

// --- Logic Params ---
uniform float border_width : hint_range(0.0, 0.1) = 0.025;
uniform float corner_radius : hint_range(0.0, 0.5) = 0.2;
uniform float center_glow_intensity : hint_range(0.0, 1.0) = 0.5;

float sd_rounded_rect(vec2 uv, vec2 size, float radius) {
    vec2 d = abs(uv - 0.5) - (size * 0.5) + radius;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - radius;
}

void fragment() {
    vec2 uv = UV;
    
    // 1. Define Geometry
    float dist = sd_rounded_rect(uv, vec2(1.0), corner_radius);
    float body_mask = smoothstep(0.01, 0.0, dist);
    // Isolate the border area specifically
    float border_mask = smoothstep(0.0, 0.01, dist + border_width) * body_mask;
    float inner_content_mask = smoothstep(0.01, 0.0, dist + border_width);

    // 2. Border Gradient (Top to Bottom)
    vec3 final_border = mix(border_bottom.rgb, border_top.rgb, uv.y);
    
    // 3. Inner Body Gradient (Bi-Linear: Vertical + Center-Out)
    vec3 vertical_color = mix(body_bottom.rgb, body_top.rgb, uv.y);
    float horizontal_factor = smoothstep(0.8, 0.0, abs(uv.x - 0.5) * 2.0);
    vec3 final_body = mix(vertical_color, body_center.rgb, horizontal_factor * center_glow_intensity);
    
    // 4. Final Mix
    // Layer 1: The background/body
    // Layer 2: The border placed on top of the edges
    vec3 composite = mix(final_body, final_border, border_mask);
    
    // Apply the shape mask for alpha transparency
    COLOR = vec4(composite, body_mask);
}
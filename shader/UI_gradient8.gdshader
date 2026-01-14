shader_type canvas_item;

// --- Uniforms ---
uniform vec4 color_top : source_color = vec4(1.0, 0.85, 0.7, 1.0); // Peach highlight
uniform vec4 color_bottom : source_color = vec4(1.0, 0.45, 0.2, 1.0); // Deep orange
uniform vec4 border_color : source_color = vec4(0.9, 0.8, 0.4, 1.0); // Gold
uniform float border_width : hint_range(0.0, 0.1) = 0.02;
uniform float corner_radius : hint_range(0.0, 0.5) = 0.2;
uniform float shine_speed : hint_range(0.0, 5.0) = 1.5;
uniform float shine_width : hint_range(0.0, 0.5) = 0.1;

// Helper function for rounded corners (SDF)
float sd_rounded_rect(vec2 uv, vec2 size, float radius) {
    vec2 d = abs(uv - 0.5) - (size * 0.5) + radius;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - radius;
}

void fragment() {
    vec2 uv = UV;
    
    // 1. Calculate Shape & Border
    float dist = sd_rounded_rect(uv, vec2(1.0), corner_radius);
    float mask = smoothstep(0.01, 0.0, dist); // Main body mask
    float border_mask = smoothstep(0.0, 0.01, dist + border_width) * mask;
    
    // 2. Base Gradient (Orange/Peach)
    vec4 base_gradient = mix(color_bottom, color_top, uv.y);
    
    // 3. Dynamic Sheen (The vertical light streak)
    float shine_pos = mod(TIME * shine_speed, 2.0) - 1.0;
    float shine = smoothstep(shine_pos - shine_width, shine_pos, uv.x) - 
                 smoothstep(shine_pos, shine_pos + shine_width, uv.x);
    shine *= (1.0 - uv.y); // Fade shine towards the bottom
    
    // 4. Composition
    vec3 final_color = mix(base_gradient.rgb, border_color.rgb, border_mask);
    final_color += shine * 0.3; // Add subtle specular glint
    
    COLOR = vec4(final_color, mask); // Use SDF mask for alpha transparency
}
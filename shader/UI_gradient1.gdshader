shader_type canvas_item;

// สีพื้นหลัง (Background Gradient)
uniform vec4 bg_color_top : source_color = vec4(0.2, 0.2, 0.2, 1.0);
uniform vec4 bg_color_bottom : source_color = vec4(0.1, 0.1, 0.1, 1.0);

// สีขอบ (Border Gradient)
uniform vec4 border_color_top : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 border_color_bottom : source_color = vec4(0.5, 0.5, 0.5, 1.0);

uniform float border_width : hint_range(0.0, 0.5) = 0.05;

void fragment() {
    vec2 uv = UV;
    
    // ตรวจสอบพื้นที่ว่าเป็นส่วนของขอบหรือไม่
    bool is_border = (uv.x < border_width || uv.x > 1.0 - border_width || 
                      uv.y < border_width || uv.y > 1.0 - border_width);
    
    // คำนวณการไล่สีพื้นหลัง
    vec4 bg_grad = mix(bg_color_top, bg_color_bottom, uv.y);
    
    // คำนวณการไล่สีขอบ
    vec4 border_grad = mix(border_color_top, border_color_bottom, uv.y);
    
    if (is_border) {
        COLOR = border_grad;
    } else {
        COLOR = bg_grad;
    }
}
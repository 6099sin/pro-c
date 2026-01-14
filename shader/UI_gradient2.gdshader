shader_type canvas_item;

// สีพื้นหลัง 4 มุม (2D Gradient)
uniform vec4 bg_tl : source_color = vec4(1.0, 0.5, 0.5, 1.0); // Top-Left
uniform vec4 bg_tr : source_color = vec4(0.5, 1.0, 0.5, 1.0); // Top-Right
uniform vec4 bg_bl : source_color = vec4(0.5, 0.5, 1.0, 1.0); // Bottom-Left
uniform vec4 bg_br : source_color = vec4(1.0, 1.0, 0.5, 1.0); // Bottom-Right

// สีขอบ (ยังคงเป็น Vertical Gradient เพื่อความสวยงาม)
uniform vec4 border_color_top : source_color = vec4(1.0);
uniform vec4 border_color_bottom : source_color = vec4(0.3);

uniform float border_width : hint_range(0.0, 0.5) = 0.05;

void fragment() {
    vec2 uv = UV;

    // 1. คำนวณ 2D Gradient สำหรับ Background
    // ผสมสีแถวบนและแถวล่างตามแนวแกน X
    vec4 top_row = mix(bg_tl, bg_tr, uv.x);
    vec4 bottom_row = mix(bg_bl, bg_br, uv.x);
    // ผสมผลลัพธ์จากแกน X เข้าด้วยกันตามแนวแกน Y
    vec4 bg_2d_grad = mix(top_row, bottom_row, uv.y);

    // 2. คำนวณ Border
    bool is_border = (uv.x < border_width || uv.x > 1.0 - border_width || 
                      uv.y < border_width || uv.y > 1.0 - border_width);
    
    vec4 border_grad = mix(border_color_top, border_color_bottom, uv.y);

    // 3. ผสมสีขั้นสุดท้าย
    if (is_border) {
        COLOR = border_grad;
    } else {
        COLOR = bg_2d_grad;
    }
}
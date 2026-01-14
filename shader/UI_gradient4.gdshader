shader_type canvas_item;

// สีตรงกลาง (Center) และ สีที่ขอบภายใน (Edge)
uniform vec4 color_center : source_color = vec4(0.2, 0.4, 0.8, 1.0);
uniform vec4 color_inner_edge : source_color = vec4(0.1, 0.2, 0.4, 1.0);

// สีขอบด้านนอกสุด (Border)
uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float border_width : hint_range(0.0, 0.5) = 0.05;

// ค่าความนุ่มนวลของการไล่สี
uniform float gradient_power : hint_range(0.1, 5.0) = 1.0;

void fragment() {
    vec2 uv = UV;
    
    // 1. ย้ายจุดศูนย์กลางไปที่ (0.5, 0.5)
    vec2 centered_uv = abs(uv - vec2(0.5)) * 2.0;
    
    // 2. Box Gradient Logic: หาค่าที่มากที่สุดระหว่างแกน X และ Y
    // วิธีนี้จะทำให้ระยะห่างมีรูปทรงเป็นสี่เหลี่ยม (Not Sphere)
    float dist = max(centered_uv.x, centered_uv.y);
    
    // ปรับแต่งความเข้มของการไล่สีด้วย Power
    float falloff = pow(dist, gradient_power);

    // 3. คำนวณสีพื้นหลัง
    vec4 bg_color = mix(color_center, color_inner_edge, clamp(falloff, 0.0, 1.0));

    // 4. สร้างขอบ (Border)
    // ตรวจสอบว่าพิกัด UV อยู่ในพื้นที่ border หรือไม่
    bool is_border = (uv.x < border_width || uv.x > 1.0 - border_width || 
                      uv.y < border_width || uv.y > 1.0 - border_width);

    // 5. แสดงผลลัพธ์
    if (is_border) {
        COLOR = border_color;
    } else {
        COLOR = bg_color;
    }
}
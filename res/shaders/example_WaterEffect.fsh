varying vec4 v_fragmentColor;  
 
uniform sampler2D tex0;  
precision highp float;  
uniform vec2 resolution;  
const float PI = 3.1415926535897932;  

const float speed = 0.1;  
const float speed_x = 0.1;  
const float speed_y = 0.1;  
 
const float intensity = 2.0;  
const int steps = 8;  
const float frequency = 3.0;  
const int angle = 7; 
 
const float delta = 20.0;  
const float intence = 200.0;  
const float emboss = 0.3;  
 
float col(vec2 coord)  
{  
    float delta_theta = 2.0 * PI / float(angle);  
    float col = 0.0;  
    float theta = 0.0;  
    for (int i = 0; i < steps; i++){
        vec2 adjc = coord;
		theta = delta_theta * float(i);
		adjc.x += cos(theta)*CC_Time.x*speed + CC_Time.x * speed_x;  
        adjc.y -= sin(theta)*CC_Time.x*speed - CC_Time.x * speed_y;  
        col = col + cos((adjc.x*cos(theta) - adjc.y*sin(theta))*frequency)*intensity;  
    }
    return cos(col);
}  

void main(void)  
{  
    vec2 p = (gl_FragCoord.xy) / resolution.xy, c1 = p, c2 = p;  
    float cc1 = col(c1);  
 
    c2.x += resolution.x/delta;  
    float dx = emboss*(cc1-col(c2))/delta;  
 
    c2.x = p.x;  
    c2.y += resolution.y/delta;  
    float dy = emboss*(cc1-col(c2))/delta;  
 
    c1.x += dx;  
    c1.y += dy;  
    float alpha = 1.0+dot(dx,dy)*intence;  
    gl_FragColor = texture2D(tex0,c1)*(alpha) *v_fragmentColor*(alpha);  
}
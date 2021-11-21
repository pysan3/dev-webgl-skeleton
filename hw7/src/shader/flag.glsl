#version 300 es
precision highp float;
in vec4 vColor;
in vec3 position;
in vec2 texcoord;
in vec3 normal;
in vec3 plight;
out vec4 color_out;

vec3 ambient(vec3 p, vec3 n, vec3 v, vec3 csurf) {
    vec3 l = n;
    vec3 clight = vec3(1.0);
    return max(0.0,dot(l,n)) * clight * csurf;
}

vec3 gooch(vec3 p, vec3 n, vec3 v, vec3 csurf) {
    vec3 ccool = vec3(0.0, 0.0, 0.55) + 0.25 * csurf;
    vec3 cwarm = vec3(0.3, 0.3, 0.0) + 0.25 * csurf;
    vec3 chigh = vec3(1.0);
    float t = (dot(n,plight) + 1.0)/2.0;
    vec3 r = -reflect( n, plight );
    float s = clamp( 100.0 * dot(r,v)-97.0, 0.0, 1.0);
    return mix( mix( ccool, cwarm, t ), chigh, s );
}

vec3 directional(vec3 p, vec3 n, vec3 v, vec3 csurf) {
   vec3 clight = normalize(vec3(0.25, 0.25, 1.0));
   return max(0.0,dot(plight,n)) * clight * csurf;
}

vec3 pointLight( vec3 p, vec3 n, vec3 v, vec3 csurf ) {
    vec3 d = plight-p; float r = sqrt(dot(d,d));
    vec3 l = d / r;
    vec3 clight = vec3(1.0) * pow( 1.5 / max( r, 1.0 ), 2.0 );
    return 0.25 * csurf + max(0.0,dot(l,n)) * clight * csurf;
}

void main() {
    color_out = vColor * 0.1;
    color_out.a = 1.0;

    color_out.rgb += ambient(
        normalize(position),
        normalize(normal),
        normalize(vec3(0.0, 0.0, 1.0)),
        color_out.rgb
    ) * 0.4;

    color_out.rgb += directional(
        normalize(position),
        normalize(normal),
        normalize(vec3(0.0, 0.0, 1.0)),
        normalize(color_out.rgb)
    ) * 0.4;

    color_out.rgb += pointLight(
        normalize(position),
        normalize(normal),
        normalize(vec3(0.0, 0.0, 1.0)),
        color_out.rgb
    ) * 0.4;
}

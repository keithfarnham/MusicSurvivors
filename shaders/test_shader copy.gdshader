shader_type canvas_item;

uniform float planeDist = 0.5;
uniform float furthest = 16.0;
uniform float fadeFrom = 8.0;

const float pi = acos(-1.0);
const float tau = 2.0 * pi;

const vec2 pathA = vec2(0.31, 0.41);
const vec2 pathB = vec2(1.0, sqrt(0.5));
const vec4 U = vec4(0.0, 1.0, 2.0, 3.0);

vec3 aces_approx(vec3 colorVec) {
    colorVec = max(colorVec, 0.0);
    colorVec *= 0.6;
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp((colorVec * (a * colorVec + b)) / (colorVec * (c * colorVec + d) + e), 0.0, 1.0);
}

vec3 offset(float zPos) {
	return vec3(pathB * sin(pathA * zPos), zPos);
}

vec3 doffset(float zPos) {
	return vec3(pathA * pathB * cos(pathA * zPos), 1.0);
}

vec3 ddoffset(float zPos) {
    return vec3(-pathA * pathA * pathB * sin(pathA * zPos), 0.0);
}

vec4 alphaBlend(vec4 backCol, vec4 frontCol) {
    // Based on: https://en.wikipedia.org/wiki/Alpha_compositing
    float w = frontCol.w + backCol.w * (1.0 - frontCol.w);
    vec3 xyz = (frontCol.xyz * frontCol.w + backCol.xyz * backCol.w * (1.0 - frontCol.w)) / w;
    return w > 0.0 ? vec4(xyz, w) : vec4(0.0);
}

float pmin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float pmax(float a, float b, float k) {
    return -pmin(-a, -b, k);
}

float pabs(float a, float k) {
    return -pmin(a, -a, k);
}

float star5(vec2 pos, float r, float rf, float sm) {
    pos = -pos;
    const vec2 k1 = vec2(0.809016994375, -0.587785252292);
    const vec2 k2 = vec2(-k1.x, k1.y);
    pos.x = abs(pos.x);
    pos -= 2.0 * max(dot(k1, pos), 0.0) * k1;
    pos -= 2.0 * max(dot(k2, pos), 0.0) * k2;
    pos.x = pabs(pos.x, sm);
    pos.y -= r;
    vec2 ba = rf * vec2(-k1.y, k1.x) - vec2(0.0, 1.0);
    float h = clamp(dot(pos, ba) / dot(ba, ba), 0.0, r);
    return length(pos - ba * h) * sign(pos.y * ba.x - pos.x * ba.y);
}

vec3 palette(float n) {
    return 0.5 + 0.5 * sin(vec3(0.0, 1.0, 2.0) + n);
}

vec4 plane(vec3 rayOrigin, vec3 rayDir, vec3 pos, vec3 normPos, float pd, vec3 cp, vec3 off, float n) {
    float aa = 3.0 * pd * distance(pos.xy, normPos.xy);
    vec4 col = vec4(0.0);
    vec2 p2 = pos.xy;
    p2 -= offset(pos.z).xy;
    vec2 doff = ddoffset(pos.z).xz;
    vec2 ddoff = doffset(pos.z).xz;
    float dd = dot(doff, ddoff);

	float cosTheta = cos(dd * pi * 5.0);
	float sinTheta = sin(dd * pi * 5.0);
	vec2 rotatedP2 = vec2(
	    cosTheta * p2.x - sinTheta * p2.y,
	    sinTheta * p2.x + cosTheta * p2.y
	);

    float d0 = star5(rotatedP2, 0.45, 1.6, 0.2) - 0.02;
    float d1 = d0 - 0.01;
    float d2 = length(rotatedP2);
    const float colp = pi * 100.0;
    float colaa = aa * 200.0;

    col.xyz = palette(0.5 * n + 2.0 * d2) * mix(0.5 / (d2 * d2), 1.0, smoothstep(-0.5 + colaa, 0.5 + colaa, sin(d2 * colp))) / max(3.0 * d2 * d2, 1E-1);
    col.xyz = mix(col.xyz, vec3(2.0), smoothstep(aa, -aa, d1));
    col.w = smoothstep(aa, -aa, -d0);
    return col;
}

vec3 color(vec3 ww, vec3 uu, vec3 vv, vec3 ro, vec2 p, vec2 res) {
    float lp = length(p);
    vec2 np = p + 1.0 / res;
    float rdd = 2.0 - 0.25;

    vec3 rd = normalize(p.x * uu + p.y * vv + rdd * ww);
    vec3 nrd = normalize(np.x * uu + np.y * vv + rdd * ww);

    float nz = floor(ro.z / planeDist);

    vec4 acol = vec4(0.0);

    vec3 aro = ro;
    float apd = 0.0;

    for (float i = 1.0; i <= furthest; ++i) {
        if (acol.w > 0.95) {
            break;
        }
        float pz = planeDist * nz + planeDist * i;

        float lpd = (pz - aro.z) / rd.z;
        float npd = (pz - aro.z) / nrd.z;
        float cpd = (pz - aro.z) / ww.z;

        {
            vec3 pp = aro + rd * lpd;
            vec3 npp = aro + nrd * npd;
            vec3 cp = aro + ww * cpd;

            apd += lpd;

            vec3 off = offset(pp.z);

            float dz = pp.z - ro.z;
            float fadeIn = smoothstep(planeDist * furthest, planeDist * fadeFrom, dz);
            float fadeOut = smoothstep(0.0, planeDist * 0.1, dz);
            float fadeOutRI = smoothstep(0.0, planeDist * 1.0, dz);

            float ri = mix(1.0, 0.9, fadeOutRI * fadeIn);

            vec4 pcol = plane(ro, rd, pp, npp, apd, cp, off, nz + i);

            pcol.w *= fadeOut * fadeIn;
            acol = alphaBlend(pcol, acol);
            aro = pp;
        }
    }

    return acol.xyz * acol.w;
}

void fragment() {
    vec2 r = SCREEN_PIXEL_SIZE;
    vec2 q = FRAGCOORD.xy / r;
    vec2 pp = -1.0 + 2.0 * q;
    vec2 p = pp;
    p.x *= r.x / r.y;

    float tm = planeDist * TIME;  // Using iTime for time

    vec3 ro = offset(tm);
    vec3 dro = doffset(tm);
    vec3 ddro = ddoffset(tm);

    vec3 ww = normalize(dro);
    vec3 uu = normalize(cross(U.xyx + ddro, ww));
    vec3 vv = cross(ww, uu);

    vec3 col = color(ww, uu, vv, ro, p, r);
    col = aces_approx(col);
    col = sqrt(col);
    COLOR = vec4(col, 1.0);
}

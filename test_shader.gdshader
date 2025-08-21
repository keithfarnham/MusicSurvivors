shader_type canvas_item;

//based on shader by mrange https://www.shadertoy.com/view/MfjyWK
const int VU_COUNT = 30;
uniform float planeDist = 0.5;
uniform float furthest = 16.0;
uniform float fadeFrom = 8.0;
uniform float[VU_COUNT] freq_data;

const float pi = acos(-1.0);
const float tau = 2.0 * pi;

const vec2 pathA = vec2(0.31, 0.41);
const vec2 pathB = vec2(1.0, sqrt(0.5));
const vec4 U = vec4(0.0, 1.0, 2.0, 3.0);

// License: Unknown, author: Matt Taylor (https://github.com/64), found: https://64.github.io/tonemapping/
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

// License: MIT, author: Inigo Quilez, found: https://iquilezles.org/articles/distfunctions2d/
//   Slightly tweaked to round the inner corners
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

float sdCircle( vec2 p, float r )
{
    return length(p) - r;
}

vec4 plane(vec3 rayOrigin, vec3 rayDirection, vec3 planePosition, vec3 normalizedPlanePosition, float planeDistance, vec3 centralPlanePosition, vec3 offsetPosition, float planeIndex) {
    float antiAliasingFactor = 3.0;// * planeDistance * distance(planePosition.xy, normalizedPlanePosition.xy);
    vec4 colorOutput = vec4(0.0);
    vec2 adjustedPlanePosition = planePosition.xy;

    //adjustedPlanePosition -= offset(planePosition.z).xy;
    //vec2 secondDerivativeOffset = ddoffset(planePosition.z).xz;
    //vec2 firstDerivativeOffset = doffset(planePosition.z).xz;
    //float derivativeDotProduct = dot(secondDerivativeOffset, firstDerivativeOffset);

    float circleDistance = sdCircle(adjustedPlanePosition / 2.0, 0.25); // Adjusted position and radius for proper scaling
    //float innerCircleDistance = circleDistance - 1.0;

    colorOutput.xyz = palette(0.5 * planeIndex + 2.0 * circleDistance);
    colorOutput.w = smoothstep(antiAliasingFactor, -antiAliasingFactor, -circleDistance);
    return colorOutput;
}

vec3 color(vec3 rayDirection, vec3 rightVector, vec3 upVector, vec3 rayOrigin, vec2 pixelCoord, vec2 resolution) {
    float pixelLength = length(pixelCoord);
    vec2 nextPixelCoord = pixelCoord + 1.0 / resolution;
    float rayDepth = 2.0 - 0.25;

    vec3 rayDir = normalize(pixelCoord.x * rightVector + pixelCoord.y * upVector + rayDepth * rayDirection);
    vec3 nextRayDir = normalize(nextPixelCoord.x * rightVector + nextPixelCoord.y * upVector + rayDepth * rayDirection);

    float planeIndex = floor(rayOrigin.z / planeDist);

    vec4 accumulatedColor = vec4(0.0);

    vec3 currentRayOrigin = rayOrigin;
    float accumulatedPlaneDist = 0.0;

    for (float planeStep = 1.0; planeStep <= furthest; ++planeStep) {
        if (accumulatedColor.w > 0.95) {
            break;
        }
        float planeZ = planeDist * planeIndex + planeDist * planeStep;

        float linearPlaneDist = (planeZ - currentRayOrigin.z) / rayDir.z;
        float nextPlaneDist = (planeZ - currentRayOrigin.z) / nextRayDir.z;
        float centralPlaneDist = (planeZ - currentRayOrigin.z) / rayDirection.z;

        {
            vec3 planeIntersection = currentRayOrigin + rayDir * linearPlaneDist;
            vec3 nextPlaneIntersection = currentRayOrigin + nextRayDir * nextPlaneDist;
            vec3 centralPlaneIntersection = currentRayOrigin + rayDirection * centralPlaneDist;

            accumulatedPlaneDist += linearPlaneDist;

            vec3 offsetPosition = offset(planeIntersection.z);

            float depthDifference = planeIntersection.z - rayOrigin.z;
            float fadeInFactor = smoothstep(planeDist * furthest, planeDist * fadeFrom, depthDifference);
            float fadeOutFactor = smoothstep(0.0, planeDist * 0.1, depthDifference);
            float fadeOutReflection = smoothstep(0.0, planeDist * 1.0, depthDifference);

            float reflectionIntensity = mix(1.0, 0.9, fadeOutReflection * fadeInFactor);

            vec4 planeColor = plane(rayOrigin, rayDir, planeIntersection, nextPlaneIntersection, accumulatedPlaneDist, centralPlaneIntersection, offsetPosition, planeIndex + planeStep);

            planeColor.w *= fadeOutFactor * fadeInFactor;
            accumulatedColor = alphaBlend(planeColor, accumulatedColor);
            currentRayOrigin = planeIntersection;
        }
    }

    return accumulatedColor.xyz * accumulatedColor.w;
}

void fragment() {
    vec2 screenPixelSize = SCREEN_PIXEL_SIZE;
    vec2 normalizedCoords = FRAGCOORD.xy / screenPixelSize;
    vec2 adjustedCoords = -1.0 + 2.0 * normalizedCoords;
    vec2 pixelCoords = adjustedCoords;
    pixelCoords.x *= screenPixelSize.x / screenPixelSize.y;

    // dividing by slow_val to slow down color changing
    float slow_val = 2.0;
    float timeOffset = planeDist * TIME / slow_val;

    vec3 rayOrigin = offset(timeOffset);
    vec3 rayOriginDerivative = doffset(timeOffset);
    vec3 rayOriginSecondDerivative = ddoffset(timeOffset);

    vec3 forwardVector = normalize(rayOriginDerivative);
    vec3 rightVector = normalize(cross(U.xyx + rayOriginSecondDerivative, forwardVector));
    vec3 upVector = cross(forwardVector, rightVector);

    vec3 finalColor = color(forwardVector, rightVector, upVector, rayOrigin, pixelCoords, screenPixelSize);

    // Sample audio data FIX THIS
    //float audioSample = texture(audio_bus, vec2(normalizedCoords.x, 0.0)).r;
    vec2 uv = UV;
	//uv.y = 1.0 - uv.y;
    float vu_count = float(VU_COUNT);
	//vec2 pos = vec2(floor(uv.x * vu_count) / vu_count, floor(uv.y * segment_count) / segment_count);
	vec2 pos = vec2(0.0, 0.0);
	//float fft = freq_data[int(uv.x * vu_count)];
    float fft = 1.0;
    finalColor *= 1.0 + 0.5 * fft; // Modulate colors with audio

    finalColor = aces_approx(finalColor);
    //finalColor = sqrt(finalColor);
    COLOR = vec4(finalColor, 1.0);
}

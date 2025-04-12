
//=====================================================================
// Refined Edge Filtering with Integrated Nodal Enhancement (v1.1)
// Target FPS Prioritized, Tenths Precision, Fully Self-Contained (.fx only)
//=====================================================================

// Removed all #includes. No external dependencies.

//=====================================================================
// UI Controls
//=====================================================================
uniform int UI_DebugView <
    ui_type = "combo";
    ui_label = "Debug View";
    ui_items = "Off\0Edge Detection\0Sample Count\0Performance OSD\0";
> = 0;

uniform float UI_EdgeDetectionThreshold <
    ui_type = "slider";
    ui_min = 0.1; ui_max = 0.3; ui_step = 0.1;
    ui_label = "Edge Detection Threshold";
> = 0.2;

uniform float UI_TargetFPS <
    ui_type = "slider";
    ui_min = 30.0; ui_max = 240.0; ui_step = 10.0;
    ui_label = "Target Framerate";
> = 120.0;

uniform int FRAME_COUNT < source = "framecount"; >;
uniform float DELTA_TIME < source = "timerdelta"; >;

//=====================================================================
// Constants
//=====================================================================
#define GOLDEN_ANGLE 2.4
#define MAX_SAMPLES 15
#define MIN_SAMPLES 3

static const int SAMPLE_VALUES[3] = {3, 9, 15};

// Safe fallback for BUFFER_SIZE and BUFFER_RCP_SIZE (manual defines)
#define BUFFER_WIDTH 1920.0
#define BUFFER_HEIGHT 1080.0
#define BUFFER_SIZE float2(BUFFER_WIDTH, BUFFER_HEIGHT)
#define BUFFER_RCP_SIZE float2(1.0 / BUFFER_WIDTH, 1.0 / BUFFER_HEIGHT)

//=====================================================================
// Textures & Samplers
//=====================================================================
texture2D texColorBuffer;
sampler2D samplerColor = sampler_state {
    Texture = texColorBuffer;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = NONE;
    AddressU = Clamp;
    AddressV = Clamp;
};

texture2D texDepth;
sampler2D samplerDepth = sampler_state {
    Texture = texDepth;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = NONE;
    AddressU = Clamp;
    AddressV = Clamp;
};

//=====================================================================
// Utility Functions
//=====================================================================
float3 GetPixelColor(float2 texcoord) { return tex2D(samplerColor, texcoord).rgb; }
float GetLuminance(float3 color) { return dot(color, float3(0.3, 0.6, 0.1)); }
float GetDepth(float2 texcoord) {
    float d = tex2D(samplerDepth, texcoord).r;
    return (d == 0.0) ? 1.0 : d;
}
float StableNoise(float2 co) {
    float2 p = frac(co * float2(444.0, 441.0));
    p += dot(p.yx, p.xy + 19.0);
    return frac(p.x * p.y * 95.0);
}

//=====================================================================
// Edge Detection (Simplified SMAA Inlined)
//=====================================================================
void EdgeDetection(float2 texcoord, float2 pixelSize, out float edgeStrength, out float2 edgeDirection) {
    float lumaM = GetLuminance(GetPixelColor(texcoord));
    float lumaR = GetLuminance(GetPixelColor(texcoord + float2(pixelSize.x, 0)));
    float lumaB = GetLuminance(GetPixelColor(texcoord + float2(0, pixelSize.y)));

    float dX = lumaR - lumaM;
    float dY = lumaB - lumaM;

    edgeStrength = sqrt(dX * dX + dY * dY);
    edgeDirection = normalize(float2(dX, dY) + 0.1);
}

//=====================================================================
// Adaptive Sample Count (Target FPS Prioritized)
//=====================================================================
int ComputeSampleCount(float frameTime, float edgeStrength) {
    float currentFPS = 1.0 / max(0.1, frameTime);
    float factor = saturate(currentFPS / UI_TargetFPS);

    int index = (factor > 1.2) ? 0 : (factor > 0.8 ? 1 : 2);
    int sampleCount = SAMPLE_VALUES[index];

    if (edgeStrength > UI_EdgeDetectionThreshold * 1.3 && factor > 0.8)
        sampleCount = min(sampleCount + 3, MAX_SAMPLES);

    return clamp(sampleCount, MIN_SAMPLES, MAX_SAMPLES);
}

//=====================================================================
// Refined Filter
//=====================================================================
float3 RefinedFilter(float2 texcoord, float2 pixelSize, float2 edgeDirection, int sampleCount) {
    float3 centerColor = GetPixelColor(texcoord);
    float centerLuma = GetLuminance(centerColor);
    float3 accum = centerColor;
    float totalWeight = 1.0;

    float2 perp = edgeDirection.yx * float2(-1.0, 1.0);

    [unroll]
    for (int i = 1; i <= sampleCount; i++) {
        float radius = float(i) * 0.7;
        float2 offset = radius * perp * pixelSize;

        float3 colorP = GetPixelColor(texcoord + offset);
        float3 colorN = GetPixelColor(texcoord - offset);

        float weightP = exp(-abs(GetLuminance(colorP) - centerLuma) * 10.0);
        float weightN = exp(-abs(GetLuminance(colorN) - centerLuma) * 10.0);

        accum += colorP * weightP + colorN * weightN;
        totalWeight += weightP + weightN;
    }

    return accum / totalWeight;
}

//=====================================================================
// OSD Overlay (Performance Display)
//=====================================================================
float3 DrawOSD(float2 texcoord, float sampleCount, float edgeStrength) {
    float2 screenPos = texcoord * BUFFER_SIZE;
    float2 pos = float2(20.0, 40.0);

    float brightness = step(length(screenPos - pos), 50.0);
    float3 color = float3(0.1, 0.8, 0.2) * brightness;

    color += float3(0.1, 0.1, 0.1) * (sampleCount / float(MAX_SAMPLES));
    color += float3(edgeStrength, 0.0, 0.0);

    return saturate(color);
}

//=====================================================================
// Main Shader
//=====================================================================
float4 mainPS(float4 vpos : SV_Position, float2 texcoord : TEXCOORD0) : SV_Target {
    float2 pixelSize = BUFFER_RCP_SIZE;

    float edgeStrength;
    float2 edgeDirection;
    EdgeDetection(texcoord, pixelSize, edgeStrength, edgeDirection);

    int sampleCount = ComputeSampleCount(DELTA_TIME, edgeStrength);
    float3 filteredColor = RefinedFilter(texcoord, pixelSize, edgeDirection, sampleCount);

    if (UI_DebugView == 1)
        return float4(float3(edgeStrength, 0.0, 0.0), 1.0);

    if (UI_DebugView == 2)
        return float4(float3(float(sampleCount) / MAX_SAMPLES), 1.0);

    if (UI_DebugView == 3)
        return float4(DrawOSD(texcoord, sampleCount, edgeStrength), 1.0);

    return float4(filteredColor, 1.0);
}

technique RefinedEdgeFiltering {
    pass {
        VertexShader = PostProcessVS;
        PixelShader = mainPS;
    }
}

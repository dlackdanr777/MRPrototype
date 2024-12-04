Shader "Neko Legends/Cel Shader/Metals"
{
    Properties
    {
        [NoScaleOffset] _Main_Texture("Main Texture", 2D) = "white" {}
        _Texture_Scale("Texture Scale", Vector) = (1, 1, 0, 0)
        _Texture_Offset("Texture Offset", Vector) = (0, 0, 0, 0)
        _Rotation("Rotation", Range(0, 360)) = 0
        _RotationOffset("RotationOffset", Vector) = (0.5, 0.5, 0, 0)
        _Color("Color", Color) = (1, 1, 1, 1)
        _Shading_Color("Shading Color", Color) = (0.490566, 0.490566, 0.490566, 1)
        [NoScaleOffset]_Metal_Texture("Metal Texture", 2D) = "white" {}
        _Metal_Texture_Scale("Metal Texture Scale", Vector) = (1, 1, 0, 0)
        _Metal_Texture_Offset("Metal Texture Offset", Vector) = (0, 0, 0, 0)
        _Metallic("Metallic", Range(0, 10)) = 1
        _Smoothness("Smoothness", Range(0, 1)) = 0.75
        _Cel_Shader_Offset("Cel Shader Offset", Range(0, 1)) = 0.5
        _Cel_Ramp_Smoothness("Cel Ramp Smoothness", Range(0, 10)) = 0
        _Alpha_Clip_Threshold("Alpha Clip Threshold", Range(0, 1)) = 0.5
        _Rim_Lighting("Rim Lighting", Range(-1, 1)) = -0.01
        _Rim_Brightness("Rim Brightness", Range(0, 5)) = 1
        _Ambient_Self_Lighting("Ambient Self Lighting", Range(0, 1)) = 0
        [NoScaleOffset]_Emissions_Mask("Emissions Mask", 2D) = "black" {}
        [ToggleUI]_UseNormalMap("UseNormalMap", Float) = 0
        [Normal][NoScaleOffset]_NormalMap("NormalMap", 2D) = "bump" {}
        [HideInInspector]_WorkflowMode("_WorkflowMode", Float) = 1
        [HideInInspector]_CastShadows("_CastShadows", Float) = 1
        [HideInInspector]_ReceiveShadows("_ReceiveShadows", Float) = 0
        [HideInInspector]_Surface("_Surface", Float) = 0
        [HideInInspector]_Blend("_Blend", Float) = 0
        [HideInInspector]_AlphaClip("_AlphaClip", Float) = 1
        [HideInInspector]_BlendModePreserveSpecular("_BlendModePreserveSpecular", Float) = 1
        [HideInInspector]_SrcBlend("_SrcBlend", Float) = 1
        [HideInInspector]_DstBlend("_DstBlend", Float) = 0
        [HideInInspector][ToggleUI]_ZWrite("_ZWrite", Float) = 1
        [HideInInspector]_ZWriteControl("_ZWriteControl", Float) = 0
        [HideInInspector]_ZTest("_ZTest", Float) = 4
        [HideInInspector]_Cull("_Cull", Float) = 2
        [HideInInspector]_AlphaToMask("_AlphaToMask", Float) = 1
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue" = "AlphaTest"
            "DisableBatching" = "LODFading"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull[_Cull]
        Blend[_SrcBlend][_DstBlend]
        ZTest[_ZTest]
        ZWrite[_ZWrite]
        AlphaToMask[_AlphaToMask]

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag

        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local_fragment _ _SPECULAR_SETUP
        #pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define USE_UNITY_CROSSFADE 1


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings(Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings(PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float2 _Metal_Texture_Scale;
        float4 _Main_Texture_TexelSize;
        float2 _Metal_Texture_Offset;
        float4 _Emissions_Mask_TexelSize;
        float2 _Texture_Offset;
        float4 _Shading_Color;
        float _Cel_Shader_Offset;
        float _Rim_Lighting;
        float _Rim_Brightness;
        float _Ambient_Self_Lighting;
        float4 _NormalMap_TexelSize;
        float _UseNormalMap;
        float _Alpha_Clip_Threshold;
        float _Cel_Ramp_Smoothness;
        float2 _Texture_Scale;
        float4 _Metal_Texture_TexelSize;
        float _Smoothness;
        float _Metallic;
        float _Rotation;
        float2 _RotationOffset;
        CBUFFER_END


            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Main_Texture);
            SAMPLER(sampler_Main_Texture);
            TEXTURE2D(_Emissions_Mask);
            SAMPLER(sampler_Emissions_Mask);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            TEXTURE2D(_Metal_Texture);
            SAMPLER(sampler_Metal_Texture);

            // Graph Includes
            #include "../Cel.hlsl"

            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif

            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif

            // Graph Functions

            void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
            {
                //rotation matrix
                Rotation = Rotation * (3.1415926f / 180.0f);
                UV -= Center;
                float s = sin(Rotation);
                float c = cos(Rotation);

                //center rotation matrix
                float2x2 rMatrix = float2x2(c, -s, s, c);
                rMatrix *= 0.5;
                rMatrix += 0.5;
                rMatrix = rMatrix * 2 - 1;

                //multiply the UVs by the rotation matrix
                UV.xy = mul(UV.xy, rMatrix);
                UV += Center;

                Out = UV;
            }

            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
            {
                Out = UV * Tiling + Offset;
            }

            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A - B;
            }

            void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
            {
                Out = Predicate ? True : False;
            }

            void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
            {
                Out = dot(A, B);
            }

            void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
            {
                Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
            }

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            void Unity_Step_float(float Edge, float In, out float Out)
            {
                Out = step(Edge, In);
            }

            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }

            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A + B;
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float3 Specular;
                float Smoothness;
                float Occlusion;
                float Alpha;
                float AlphaClipThreshold;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
                float2 _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2 = _RotationOffset;
                float _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float = _Rotation;
                float2 _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2;
                Unity_Rotate_Degrees_float(IN.uv0.xy, _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2, _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float, _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2);
                float2 _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2 = _Texture_Scale;
                float2 _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2 = _Texture_Offset;
                float2 _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2;
                Unity_TilingAndOffset_float(_Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2, _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2, _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2, _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2);
                float4 _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.tex, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.samplerstate, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2));
                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_R_4_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.r;
                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_G_5_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.g;
                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_B_6_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.b;
                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.a;
                float4 _Property_fdab52b7937644c6bd147c5450c3f251_Out_0_Vector4 = _Color;
                float4 _Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4;
                Unity_Multiply_float4_float4(_SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4, _Property_fdab52b7937644c6bd147c5450c3f251_Out_0_Vector4, _Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4);
                UnityTexture2D _Property_2a814b19185d49e0b94d6605f815fc22_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Emissions_Mask);
                float4 _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2a814b19185d49e0b94d6605f815fc22_Out_0_Texture2D.tex, _Property_2a814b19185d49e0b94d6605f815fc22_Out_0_Texture2D.samplerstate, _Property_2a814b19185d49e0b94d6605f815fc22_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                float _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_R_4_Float = _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4.r;
                float _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_G_5_Float = _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4.g;
                float _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_B_6_Float = _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4.b;
                float _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_A_7_Float = _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4.a;
                float4 _Multiply_08eeabd84e22476193f424c2d7c85045_Out_2_Vector4;
                Unity_Multiply_float4_float4(_Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4, (_SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_R_4_Float.xxxx), _Multiply_08eeabd84e22476193f424c2d7c85045_Out_2_Vector4);
                float _Property_f4350f6cd94f4ff688723b2601758647_Out_0_Boolean = _UseNormalMap;
                UnityTexture2D _Property_2935e6b933c9464c9a226e3939202d3f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
                float4 _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2935e6b933c9464c9a226e3939202d3f_Out_0_Texture2D.tex, _Property_2935e6b933c9464c9a226e3939202d3f_Out_0_Texture2D.samplerstate, _Property_2935e6b933c9464c9a226e3939202d3f_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                float _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_R_4_Float = _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4.r;
                float _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_G_5_Float = _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4.g;
                float _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_B_6_Float = _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4.b;
                float _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_A_7_Float = _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4.a;
                float4 _Subtract_97b8413d701a46f89b6a6a50965c849b_Out_2_Vector4;
                Unity_Subtract_float4(_SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4, float4(0.5, 0.5, 0.5, 0.5), _Subtract_97b8413d701a46f89b6a6a50965c849b_Out_2_Vector4);
                float4 _Multiply_c404d82a7afb45eea38c0f2f8913b3a2_Out_2_Vector4;
                Unity_Multiply_float4_float4(_Subtract_97b8413d701a46f89b6a6a50965c849b_Out_2_Vector4, float4(2, 2, 2, 2), _Multiply_c404d82a7afb45eea38c0f2f8913b3a2_Out_2_Vector4);
                float3 _Branch_f5eae9fa1f90448eabeacd6c1897a242_Out_3_Vector3;
                Unity_Branch_float3(_Property_f4350f6cd94f4ff688723b2601758647_Out_0_Boolean, (_Multiply_c404d82a7afb45eea38c0f2f8913b3a2_Out_2_Vector4.xyz), IN.WorldSpaceNormal, _Branch_f5eae9fa1f90448eabeacd6c1897a242_Out_3_Vector3);
                float _Property_5c3b0e65e43446d3ae6a44d69cece6ed_Out_0_Float = _Cel_Ramp_Smoothness;
                float4 _Property_3bfe113ecee2425dbb2ce8c43d76f557_Out_0_Vector4 = _Shading_Color;
                float _Property_0562fc1a3d1841be83d39c63b4485cee_Out_0_Float = _Cel_Shader_Offset;
                float Slider_8d27041afd1d4a0c9c60c067176a44c9 = 0.5;
                float _Property_cbc4f53f5a8e4226b87bb2246a5ed158_Out_0_Float = _Ambient_Self_Lighting;
                float3 _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_ToonRampOutput_0_Vector3;
                float3 _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_Direction_7_Vector3;
                CelShading_float(_Branch_f5eae9fa1f90448eabeacd6c1897a242_Out_3_Vector3, _Property_5c3b0e65e43446d3ae6a44d69cece6ed_Out_0_Float, IN.ObjectSpacePosition, IN.WorldSpacePosition, (_Property_3bfe113ecee2425dbb2ce8c43d76f557_Out_0_Vector4.xyz), _Property_0562fc1a3d1841be83d39c63b4485cee_Out_0_Float, Slider_8d27041afd1d4a0c9c60c067176a44c9, _Property_cbc4f53f5a8e4226b87bb2246a5ed158_Out_0_Float, _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_ToonRampOutput_0_Vector3, _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_Direction_7_Vector3);
                float _DotProduct_869fe8cb72874c72aabcc111591a62cd_Out_2_Float;
                Unity_DotProduct_float3(_Branch_f5eae9fa1f90448eabeacd6c1897a242_Out_3_Vector3, _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_Direction_7_Vector3, _DotProduct_869fe8cb72874c72aabcc111591a62cd_Out_2_Float);
                float _Property_bd8d78e287724bebbeb518d7e1ab0c20_Out_0_Float = _Rim_Lighting;
                float _FresnelEffect_f452c68b8d004619bb2fa547d94e8942_Out_3_Float;
                Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_bd8d78e287724bebbeb518d7e1ab0c20_Out_0_Float, _FresnelEffect_f452c68b8d004619bb2fa547d94e8942_Out_3_Float);
                float _Multiply_500bfd19683e48cbbfd9139fcb7dc218_Out_2_Float;
                Unity_Multiply_float_float(_DotProduct_869fe8cb72874c72aabcc111591a62cd_Out_2_Float, _FresnelEffect_f452c68b8d004619bb2fa547d94e8942_Out_3_Float, _Multiply_500bfd19683e48cbbfd9139fcb7dc218_Out_2_Float);
                float _Step_48bb4a882f094cbc9be0e421634c6929_Out_2_Float;
                Unity_Step_float(float(0.5), _Multiply_500bfd19683e48cbbfd9139fcb7dc218_Out_2_Float, _Step_48bb4a882f094cbc9be0e421634c6929_Out_2_Float);
                float4 _Multiply_1950ac11d2144717b01dc351ee1c8986_Out_2_Vector4;
                Unity_Multiply_float4_float4(_Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4, (_Step_48bb4a882f094cbc9be0e421634c6929_Out_2_Float.xxxx), _Multiply_1950ac11d2144717b01dc351ee1c8986_Out_2_Vector4);
                float _Property_c341dd541b3a425d9d9823d7984f6bf5_Out_0_Float = _Rim_Brightness;
                float4 _Multiply_91b3bc779fce42e0af22ce8684a3e501_Out_2_Vector4;
                Unity_Multiply_float4_float4(_Multiply_1950ac11d2144717b01dc351ee1c8986_Out_2_Vector4, (_Property_c341dd541b3a425d9d9823d7984f6bf5_Out_0_Float.xxxx), _Multiply_91b3bc779fce42e0af22ce8684a3e501_Out_2_Vector4);
                float3 _Multiply_55211470d6b746f5b5fecb73a5dea81b_Out_2_Vector3;
                Unity_Multiply_float3_float3((_Multiply_91b3bc779fce42e0af22ce8684a3e501_Out_2_Vector4.xyz), _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_ToonRampOutput_0_Vector3, _Multiply_55211470d6b746f5b5fecb73a5dea81b_Out_2_Vector3);
                float3 _Multiply_6208b7b8f0c543e78a2446e5fc4eb226_Out_2_Vector3;
                Unity_Multiply_float3_float3((_Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4.xyz), _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_ToonRampOutput_0_Vector3, _Multiply_6208b7b8f0c543e78a2446e5fc4eb226_Out_2_Vector3);
                float3 _Add_6c8423e60dfd4875874ca92d4f743b9e_Out_2_Vector3;
                Unity_Add_float3(_Multiply_55211470d6b746f5b5fecb73a5dea81b_Out_2_Vector3, _Multiply_6208b7b8f0c543e78a2446e5fc4eb226_Out_2_Vector3, _Add_6c8423e60dfd4875874ca92d4f743b9e_Out_2_Vector3);
                float3 _Add_e9066678904e4fd590e41227b2822728_Out_2_Vector3;
                Unity_Add_float3((_Multiply_08eeabd84e22476193f424c2d7c85045_Out_2_Vector4.xyz), _Add_6c8423e60dfd4875874ca92d4f743b9e_Out_2_Vector3, _Add_e9066678904e4fd590e41227b2822728_Out_2_Vector3);
                UnityTexture2D _Property_e729de346fa74051ad1c8d0f2e70950d_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Metal_Texture);
                float2 _Property_6f45e75fb82543a090ae85930da02135_Out_0_Vector2 = _Metal_Texture_Scale;
                float2 _Property_11ef0af2bfac4b56abf271def4ab8ca3_Out_0_Vector2 = _Metal_Texture_Offset;
                float2 _TilingAndOffset_cce3caa9bbd448c1982679f9991c75ba_Out_3_Vector2;
                Unity_TilingAndOffset_float(IN.uv0.xy, _Property_6f45e75fb82543a090ae85930da02135_Out_0_Vector2, _Property_11ef0af2bfac4b56abf271def4ab8ca3_Out_0_Vector2, _TilingAndOffset_cce3caa9bbd448c1982679f9991c75ba_Out_3_Vector2);
                float4 _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e729de346fa74051ad1c8d0f2e70950d_Out_0_Texture2D.tex, _Property_e729de346fa74051ad1c8d0f2e70950d_Out_0_Texture2D.samplerstate, _Property_e729de346fa74051ad1c8d0f2e70950d_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_cce3caa9bbd448c1982679f9991c75ba_Out_3_Vector2));
                float _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_R_4_Float = _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_RGBA_0_Vector4.r;
                float _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_G_5_Float = _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_RGBA_0_Vector4.g;
                float _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_B_6_Float = _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_RGBA_0_Vector4.b;
                float _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_A_7_Float = _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_RGBA_0_Vector4.a;
                float _Property_0a4f720fc01d46109f6448e9b330d623_Out_0_Float = _Metallic;
                float3 _Multiply_4621936805b64076821b51bde2b6736e_Out_2_Vector3;
                Unity_Multiply_float3_float3(_Add_6c8423e60dfd4875874ca92d4f743b9e_Out_2_Vector3, (_Property_0a4f720fc01d46109f6448e9b330d623_Out_0_Float.xxx), _Multiply_4621936805b64076821b51bde2b6736e_Out_2_Vector3);
                float3 _Multiply_e03d5b3a3d8f4332be3fad0fd978ee0f_Out_2_Vector3;
                Unity_Multiply_float3_float3((_SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_R_4_Float.xxx), _Multiply_4621936805b64076821b51bde2b6736e_Out_2_Vector3, _Multiply_e03d5b3a3d8f4332be3fad0fd978ee0f_Out_2_Vector3);
                float _Property_1e53bd5f23b2455585ffd4f1c939cd7c_Out_0_Float = _Smoothness;
                float _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float = _Alpha_Clip_Threshold;
                surface.BaseColor = _Add_e9066678904e4fd590e41227b2822728_Out_2_Vector3;
                surface.NormalTS = IN.TangentSpaceNormal;
                surface.Emission = _Add_e9066678904e4fd590e41227b2822728_Out_2_Vector3;
                surface.Metallic = (_Multiply_e03d5b3a3d8f4332be3fad0fd978ee0f_Out_2_Vector3).x;
                surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                surface.Smoothness = _Property_1e53bd5f23b2455585ffd4f1c939cd7c_Out_0_Float;
                surface.Occlusion = float(0);
                surface.Alpha = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float;
                surface.AlphaClipThreshold = _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            #ifdef HAVE_VFX_MODIFICATION
            #if VFX_USE_GRAPH_VALUES
                uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
            #endif
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

            #endif



                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                float3 unnormalizedNormalWS = input.normalWS;
                const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                output.WorldSpacePosition = input.positionWS;
                output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);

                #if UNITY_UV_STARTS_AT_TOP
                #else
                #endif


                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                    return output;
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif

            ENDHLSL
            }
            Pass
            {
                Name "GBuffer"
                Tags
                {
                    "LightMode" = "UniversalGBuffer"
                }

                // Render State
                Cull[_Cull]
                Blend[_SrcBlend][_DstBlend]
                ZTest[_ZTest]
                ZWrite[_ZWrite]

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                HLSLPROGRAM

                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma vertex vert
                #pragma fragment frag

                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
                #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
                #pragma multi_compile_fragment _ DEBUG_DISPLAY
                #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
                #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
                #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
                #pragma shader_feature_local_fragment _ _ALPHATEST_ON
                #pragma shader_feature_local_fragment _ _SPECULAR_SETUP
                #pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF
                #pragma multi_compile _ LOD_FADE_CROSSFADE
                // GraphKeywords: <None>

                // Defines

                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define VARYINGS_NEED_SHADOW_COORD
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_GBUFFER
                #define _FOG_FRAGMENT 1
                #define USE_UNITY_CROSSFADE 1


                // custom interpolator pre-include
                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                // Includes
                #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
                #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

                // --------------------------------------------------
                // Structs and Packing

                // custom interpolators pre packing
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpaceNormal;
                     float3 TangentSpaceNormal;
                     float3 WorldSpaceViewDirection;
                     float3 ObjectSpacePosition;
                     float3 WorldSpacePosition;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV : INTERP0;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV : INTERP1;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh : INTERP2;
                    #endif
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord : INTERP3;
                    #endif
                     float4 tangentWS : INTERP4;
                     float4 texCoord0 : INTERP5;
                     float4 fogFactorAndVertexLight : INTERP6;
                     float3 positionWS : INTERP7;
                     float3 normalWS : INTERP8;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.sh;
                    #endif
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.shadowCoord;
                    #endif
                    output.tangentWS.xyzw = input.tangentWS;
                    output.texCoord0.xyzw = input.texCoord0;
                    output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
                    output.positionWS.xyz = input.positionWS;
                    output.normalWS.xyz = input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.sh;
                    #endif
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.shadowCoord;
                    #endif
                    output.tangentWS = input.tangentWS.xyzw;
                    output.texCoord0 = input.texCoord0.xyzw;
                    output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
                    output.positionWS = input.positionWS.xyz;
                    output.normalWS = input.normalWS.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }


                // --------------------------------------------------
                // Graph

                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float2 _Metal_Texture_Scale;
                float4 _Main_Texture_TexelSize;
                float2 _Metal_Texture_Offset;
                float4 _Emissions_Mask_TexelSize;
                float2 _Texture_Offset;
                float4 _Shading_Color;
                float _Cel_Shader_Offset;
                float _Rim_Lighting;
                float _Rim_Brightness;
                float _Ambient_Self_Lighting;
                float4 _NormalMap_TexelSize;
                float _UseNormalMap;
                float _Alpha_Clip_Threshold;
                float _Cel_Ramp_Smoothness;
                float2 _Texture_Scale;
                float4 _Metal_Texture_TexelSize;
                float _Smoothness;
                float _Metallic;
                float _Rotation;
                float2 _RotationOffset;
                CBUFFER_END


                    // Object and Global properties
                    SAMPLER(SamplerState_Linear_Repeat);
                    TEXTURE2D(_Main_Texture);
                    SAMPLER(sampler_Main_Texture);
                    TEXTURE2D(_Emissions_Mask);
                    SAMPLER(sampler_Emissions_Mask);
                    TEXTURE2D(_NormalMap);
                    SAMPLER(sampler_NormalMap);
                    TEXTURE2D(_Metal_Texture);
                    SAMPLER(sampler_Metal_Texture);

                    // Graph Includes
                    #include "../Cel.hlsl"

                    // -- Property used by ScenePickingPass
                    #ifdef SCENEPICKINGPASS
                    float4 _SelectionID;
                    #endif

                    // -- Properties used by SceneSelectionPass
                    #ifdef SCENESELECTIONPASS
                    int _ObjectId;
                    int _PassValue;
                    #endif

                    // Graph Functions

                    void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                    {
                        //rotation matrix
                        Rotation = Rotation * (3.1415926f / 180.0f);
                        UV -= Center;
                        float s = sin(Rotation);
                        float c = cos(Rotation);

                        //center rotation matrix
                        float2x2 rMatrix = float2x2(c, -s, s, c);
                        rMatrix *= 0.5;
                        rMatrix += 0.5;
                        rMatrix = rMatrix * 2 - 1;

                        //multiply the UVs by the rotation matrix
                        UV.xy = mul(UV.xy, rMatrix);
                        UV += Center;

                        Out = UV;
                    }

                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                    {
                        Out = UV * Tiling + Offset;
                    }

                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = A - B;
                    }

                    void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
                    {
                        Out = Predicate ? True : False;
                    }

                    void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                    {
                        Out = dot(A, B);
                    }

                    void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
                    {
                        Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
                    }

                    void Unity_Multiply_float_float(float A, float B, out float Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Step_float(float Edge, float In, out float Out)
                    {
                        Out = step(Edge, In);
                    }

                    void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                    {
                        Out = A + B;
                    }

                    // Custom interpolators pre vertex
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                    // Graph Vertex
                    struct VertexDescription
                    {
                        float3 Position;
                        float3 Normal;
                        float3 Tangent;
                    };

                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                    {
                        VertexDescription description = (VertexDescription)0;
                        description.Position = IN.ObjectSpacePosition;
                        description.Normal = IN.ObjectSpaceNormal;
                        description.Tangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Custom interpolators, pre surface
                    #ifdef FEATURES_GRAPH_VERTEX
                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                    {
                    return output;
                    }
                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                    #endif

                    // Graph Pixel
                    struct SurfaceDescription
                    {
                        float3 BaseColor;
                        float3 NormalTS;
                        float3 Emission;
                        float Metallic;
                        float3 Specular;
                        float Smoothness;
                        float Occlusion;
                        float Alpha;
                        float AlphaClipThreshold;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        UnityTexture2D _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
                        float2 _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2 = _RotationOffset;
                        float _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float = _Rotation;
                        float2 _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2;
                        Unity_Rotate_Degrees_float(IN.uv0.xy, _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2, _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float, _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2);
                        float2 _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2 = _Texture_Scale;
                        float2 _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2 = _Texture_Offset;
                        float2 _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2;
                        Unity_TilingAndOffset_float(_Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2, _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2, _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2, _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2);
                        float4 _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.tex, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.samplerstate, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2));
                        float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_R_4_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.r;
                        float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_G_5_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.g;
                        float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_B_6_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.b;
                        float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.a;
                        float4 _Property_fdab52b7937644c6bd147c5450c3f251_Out_0_Vector4 = _Color;
                        float4 _Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4;
                        Unity_Multiply_float4_float4(_SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4, _Property_fdab52b7937644c6bd147c5450c3f251_Out_0_Vector4, _Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4);
                        UnityTexture2D _Property_2a814b19185d49e0b94d6605f815fc22_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Emissions_Mask);
                        float4 _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2a814b19185d49e0b94d6605f815fc22_Out_0_Texture2D.tex, _Property_2a814b19185d49e0b94d6605f815fc22_Out_0_Texture2D.samplerstate, _Property_2a814b19185d49e0b94d6605f815fc22_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                        float _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_R_4_Float = _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4.r;
                        float _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_G_5_Float = _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4.g;
                        float _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_B_6_Float = _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4.b;
                        float _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_A_7_Float = _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4.a;
                        float4 _Multiply_08eeabd84e22476193f424c2d7c85045_Out_2_Vector4;
                        Unity_Multiply_float4_float4(_Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4, (_SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_R_4_Float.xxxx), _Multiply_08eeabd84e22476193f424c2d7c85045_Out_2_Vector4);
                        float _Property_f4350f6cd94f4ff688723b2601758647_Out_0_Boolean = _UseNormalMap;
                        UnityTexture2D _Property_2935e6b933c9464c9a226e3939202d3f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
                        float4 _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2935e6b933c9464c9a226e3939202d3f_Out_0_Texture2D.tex, _Property_2935e6b933c9464c9a226e3939202d3f_Out_0_Texture2D.samplerstate, _Property_2935e6b933c9464c9a226e3939202d3f_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                        float _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_R_4_Float = _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4.r;
                        float _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_G_5_Float = _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4.g;
                        float _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_B_6_Float = _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4.b;
                        float _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_A_7_Float = _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4.a;
                        float4 _Subtract_97b8413d701a46f89b6a6a50965c849b_Out_2_Vector4;
                        Unity_Subtract_float4(_SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4, float4(0.5, 0.5, 0.5, 0.5), _Subtract_97b8413d701a46f89b6a6a50965c849b_Out_2_Vector4);
                        float4 _Multiply_c404d82a7afb45eea38c0f2f8913b3a2_Out_2_Vector4;
                        Unity_Multiply_float4_float4(_Subtract_97b8413d701a46f89b6a6a50965c849b_Out_2_Vector4, float4(2, 2, 2, 2), _Multiply_c404d82a7afb45eea38c0f2f8913b3a2_Out_2_Vector4);
                        float3 _Branch_f5eae9fa1f90448eabeacd6c1897a242_Out_3_Vector3;
                        Unity_Branch_float3(_Property_f4350f6cd94f4ff688723b2601758647_Out_0_Boolean, (_Multiply_c404d82a7afb45eea38c0f2f8913b3a2_Out_2_Vector4.xyz), IN.WorldSpaceNormal, _Branch_f5eae9fa1f90448eabeacd6c1897a242_Out_3_Vector3);
                        float _Property_5c3b0e65e43446d3ae6a44d69cece6ed_Out_0_Float = _Cel_Ramp_Smoothness;
                        float4 _Property_3bfe113ecee2425dbb2ce8c43d76f557_Out_0_Vector4 = _Shading_Color;
                        float _Property_0562fc1a3d1841be83d39c63b4485cee_Out_0_Float = _Cel_Shader_Offset;
                        float Slider_8d27041afd1d4a0c9c60c067176a44c9 = 0.5;
                        float _Property_cbc4f53f5a8e4226b87bb2246a5ed158_Out_0_Float = _Ambient_Self_Lighting;
                        float3 _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_ToonRampOutput_0_Vector3;
                        float3 _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_Direction_7_Vector3;
                        CelShading_float(_Branch_f5eae9fa1f90448eabeacd6c1897a242_Out_3_Vector3, _Property_5c3b0e65e43446d3ae6a44d69cece6ed_Out_0_Float, IN.ObjectSpacePosition, IN.WorldSpacePosition, (_Property_3bfe113ecee2425dbb2ce8c43d76f557_Out_0_Vector4.xyz), _Property_0562fc1a3d1841be83d39c63b4485cee_Out_0_Float, Slider_8d27041afd1d4a0c9c60c067176a44c9, _Property_cbc4f53f5a8e4226b87bb2246a5ed158_Out_0_Float, _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_ToonRampOutput_0_Vector3, _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_Direction_7_Vector3);
                        float _DotProduct_869fe8cb72874c72aabcc111591a62cd_Out_2_Float;
                        Unity_DotProduct_float3(_Branch_f5eae9fa1f90448eabeacd6c1897a242_Out_3_Vector3, _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_Direction_7_Vector3, _DotProduct_869fe8cb72874c72aabcc111591a62cd_Out_2_Float);
                        float _Property_bd8d78e287724bebbeb518d7e1ab0c20_Out_0_Float = _Rim_Lighting;
                        float _FresnelEffect_f452c68b8d004619bb2fa547d94e8942_Out_3_Float;
                        Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_bd8d78e287724bebbeb518d7e1ab0c20_Out_0_Float, _FresnelEffect_f452c68b8d004619bb2fa547d94e8942_Out_3_Float);
                        float _Multiply_500bfd19683e48cbbfd9139fcb7dc218_Out_2_Float;
                        Unity_Multiply_float_float(_DotProduct_869fe8cb72874c72aabcc111591a62cd_Out_2_Float, _FresnelEffect_f452c68b8d004619bb2fa547d94e8942_Out_3_Float, _Multiply_500bfd19683e48cbbfd9139fcb7dc218_Out_2_Float);
                        float _Step_48bb4a882f094cbc9be0e421634c6929_Out_2_Float;
                        Unity_Step_float(float(0.5), _Multiply_500bfd19683e48cbbfd9139fcb7dc218_Out_2_Float, _Step_48bb4a882f094cbc9be0e421634c6929_Out_2_Float);
                        float4 _Multiply_1950ac11d2144717b01dc351ee1c8986_Out_2_Vector4;
                        Unity_Multiply_float4_float4(_Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4, (_Step_48bb4a882f094cbc9be0e421634c6929_Out_2_Float.xxxx), _Multiply_1950ac11d2144717b01dc351ee1c8986_Out_2_Vector4);
                        float _Property_c341dd541b3a425d9d9823d7984f6bf5_Out_0_Float = _Rim_Brightness;
                        float4 _Multiply_91b3bc779fce42e0af22ce8684a3e501_Out_2_Vector4;
                        Unity_Multiply_float4_float4(_Multiply_1950ac11d2144717b01dc351ee1c8986_Out_2_Vector4, (_Property_c341dd541b3a425d9d9823d7984f6bf5_Out_0_Float.xxxx), _Multiply_91b3bc779fce42e0af22ce8684a3e501_Out_2_Vector4);
                        float3 _Multiply_55211470d6b746f5b5fecb73a5dea81b_Out_2_Vector3;
                        Unity_Multiply_float3_float3((_Multiply_91b3bc779fce42e0af22ce8684a3e501_Out_2_Vector4.xyz), _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_ToonRampOutput_0_Vector3, _Multiply_55211470d6b746f5b5fecb73a5dea81b_Out_2_Vector3);
                        float3 _Multiply_6208b7b8f0c543e78a2446e5fc4eb226_Out_2_Vector3;
                        Unity_Multiply_float3_float3((_Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4.xyz), _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_ToonRampOutput_0_Vector3, _Multiply_6208b7b8f0c543e78a2446e5fc4eb226_Out_2_Vector3);
                        float3 _Add_6c8423e60dfd4875874ca92d4f743b9e_Out_2_Vector3;
                        Unity_Add_float3(_Multiply_55211470d6b746f5b5fecb73a5dea81b_Out_2_Vector3, _Multiply_6208b7b8f0c543e78a2446e5fc4eb226_Out_2_Vector3, _Add_6c8423e60dfd4875874ca92d4f743b9e_Out_2_Vector3);
                        float3 _Add_e9066678904e4fd590e41227b2822728_Out_2_Vector3;
                        Unity_Add_float3((_Multiply_08eeabd84e22476193f424c2d7c85045_Out_2_Vector4.xyz), _Add_6c8423e60dfd4875874ca92d4f743b9e_Out_2_Vector3, _Add_e9066678904e4fd590e41227b2822728_Out_2_Vector3);
                        UnityTexture2D _Property_e729de346fa74051ad1c8d0f2e70950d_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Metal_Texture);
                        float2 _Property_6f45e75fb82543a090ae85930da02135_Out_0_Vector2 = _Metal_Texture_Scale;
                        float2 _Property_11ef0af2bfac4b56abf271def4ab8ca3_Out_0_Vector2 = _Metal_Texture_Offset;
                        float2 _TilingAndOffset_cce3caa9bbd448c1982679f9991c75ba_Out_3_Vector2;
                        Unity_TilingAndOffset_float(IN.uv0.xy, _Property_6f45e75fb82543a090ae85930da02135_Out_0_Vector2, _Property_11ef0af2bfac4b56abf271def4ab8ca3_Out_0_Vector2, _TilingAndOffset_cce3caa9bbd448c1982679f9991c75ba_Out_3_Vector2);
                        float4 _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e729de346fa74051ad1c8d0f2e70950d_Out_0_Texture2D.tex, _Property_e729de346fa74051ad1c8d0f2e70950d_Out_0_Texture2D.samplerstate, _Property_e729de346fa74051ad1c8d0f2e70950d_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_cce3caa9bbd448c1982679f9991c75ba_Out_3_Vector2));
                        float _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_R_4_Float = _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_RGBA_0_Vector4.r;
                        float _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_G_5_Float = _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_RGBA_0_Vector4.g;
                        float _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_B_6_Float = _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_RGBA_0_Vector4.b;
                        float _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_A_7_Float = _SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_RGBA_0_Vector4.a;
                        float _Property_0a4f720fc01d46109f6448e9b330d623_Out_0_Float = _Metallic;
                        float3 _Multiply_4621936805b64076821b51bde2b6736e_Out_2_Vector3;
                        Unity_Multiply_float3_float3(_Add_6c8423e60dfd4875874ca92d4f743b9e_Out_2_Vector3, (_Property_0a4f720fc01d46109f6448e9b330d623_Out_0_Float.xxx), _Multiply_4621936805b64076821b51bde2b6736e_Out_2_Vector3);
                        float3 _Multiply_e03d5b3a3d8f4332be3fad0fd978ee0f_Out_2_Vector3;
                        Unity_Multiply_float3_float3((_SampleTexture2D_494f3343bd6e4b108e2208661e0a4048_R_4_Float.xxx), _Multiply_4621936805b64076821b51bde2b6736e_Out_2_Vector3, _Multiply_e03d5b3a3d8f4332be3fad0fd978ee0f_Out_2_Vector3);
                        float _Property_1e53bd5f23b2455585ffd4f1c939cd7c_Out_0_Float = _Smoothness;
                        float _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float = _Alpha_Clip_Threshold;
                        surface.BaseColor = _Add_e9066678904e4fd590e41227b2822728_Out_2_Vector3;
                        surface.NormalTS = IN.TangentSpaceNormal;
                        surface.Emission = _Add_e9066678904e4fd590e41227b2822728_Out_2_Vector3;
                        surface.Metallic = (_Multiply_e03d5b3a3d8f4332be3fad0fd978ee0f_Out_2_Vector3).x;
                        surface.Specular = IsGammaSpace() ? float3(0.5, 0.5, 0.5) : SRGBToLinear(float3(0.5, 0.5, 0.5));
                        surface.Smoothness = _Property_1e53bd5f23b2455585ffd4f1c939cd7c_Out_0_Float;
                        surface.Occlusion = float(0);
                        surface.Alpha = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float;
                        surface.AlphaClipThreshold = _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs
                    #ifdef HAVE_VFX_MODIFICATION
                    #define VFX_SRP_ATTRIBUTES Attributes
                    #define VFX_SRP_VARYINGS Varyings
                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                    #endif
                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                    {
                        VertexDescriptionInputs output;
                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                        output.ObjectSpaceNormal = input.normalOS;
                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                        output.ObjectSpacePosition = input.positionOS;

                        return output;
                    }
                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                    #ifdef HAVE_VFX_MODIFICATION
                    #if VFX_USE_GRAPH_VALUES
                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                    #endif
                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                    #endif



                        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                        float3 unnormalizedNormalWS = input.normalWS;
                        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                        output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                        output.WorldSpacePosition = input.positionWS;
                        output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);

                        #if UNITY_UV_STARTS_AT_TOP
                        #else
                        #endif


                        output.uv0 = input.texCoord0;
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                    #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                    #endif
                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                            return output;
                    }

                    // --------------------------------------------------
                    // Main

                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

                    // --------------------------------------------------
                    // Visual Effect Vertex Invocations
                    #ifdef HAVE_VFX_MODIFICATION
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                    #endif

                    ENDHLSL
                    }
                    Pass
                    {
                        Name "ShadowCaster"
                        Tags
                        {
                            "LightMode" = "ShadowCaster"
                        }

                        // Render State
                        Cull[_Cull]
                        ZTest LEqual
                        ZWrite On
                        ColorMask 0

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        HLSLPROGRAM

                        // Pragmas
                        #pragma target 2.0
                        #pragma multi_compile_instancing
                        #pragma vertex vert
                        #pragma fragment frag

                        // Keywords
                        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
                        #pragma multi_compile _ LOD_FADE_CROSSFADE
                        // GraphKeywords: <None>

                        // Defines

                        #define _NORMALMAP 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define ATTRIBUTES_NEED_TEXCOORD0
                        #define VARYINGS_NEED_NORMAL_WS
                        #define VARYINGS_NEED_TEXCOORD0
                        #define FEATURES_GRAPH_VERTEX
                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                        #define SHADERPASS SHADERPASS_SHADOWCASTER
                        #define USE_UNITY_CROSSFADE 1


                        // custom interpolator pre-include
                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                        // Includes
                        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

                        // --------------------------------------------------
                        // Structs and Packing

                        // custom interpolators pre packing
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                        struct Attributes
                        {
                             float3 positionOS : POSITION;
                             float3 normalOS : NORMAL;
                             float4 tangentOS : TANGENT;
                             float4 uv0 : TEXCOORD0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 normalWS;
                             float4 texCoord0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };
                        struct SurfaceDescriptionInputs
                        {
                             float4 uv0;
                        };
                        struct VertexDescriptionInputs
                        {
                             float3 ObjectSpaceNormal;
                             float3 ObjectSpaceTangent;
                             float3 ObjectSpacePosition;
                        };
                        struct PackedVaryings
                        {
                             float4 positionCS : SV_POSITION;
                             float4 texCoord0 : INTERP0;
                             float3 normalWS : INTERP1;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output;
                            ZERO_INITIALIZE(PackedVaryings, output);
                            output.positionCS = input.positionCS;
                            output.texCoord0.xyzw = input.texCoord0;
                            output.normalWS.xyz = input.normalWS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output;
                            output.positionCS = input.positionCS;
                            output.texCoord0 = input.texCoord0.xyzw;
                            output.normalWS = input.normalWS.xyz;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }


                        // --------------------------------------------------
                        // Graph

                        // Graph Properties
                        CBUFFER_START(UnityPerMaterial)
                        float4 _Color;
                        float2 _Metal_Texture_Scale;
                        float4 _Main_Texture_TexelSize;
                        float2 _Metal_Texture_Offset;
                        float4 _Emissions_Mask_TexelSize;
                        float2 _Texture_Offset;
                        float4 _Shading_Color;
                        float _Cel_Shader_Offset;
                        float _Rim_Lighting;
                        float _Rim_Brightness;
                        float _Ambient_Self_Lighting;
                        float4 _NormalMap_TexelSize;
                        float _UseNormalMap;
                        float _Alpha_Clip_Threshold;
                        float _Cel_Ramp_Smoothness;
                        float2 _Texture_Scale;
                        float4 _Metal_Texture_TexelSize;
                        float _Smoothness;
                        float _Metallic;
                        float _Rotation;
                        float2 _RotationOffset;
                        CBUFFER_END


                            // Object and Global properties
                            SAMPLER(SamplerState_Linear_Repeat);
                            TEXTURE2D(_Main_Texture);
                            SAMPLER(sampler_Main_Texture);
                            TEXTURE2D(_Emissions_Mask);
                            SAMPLER(sampler_Emissions_Mask);
                            TEXTURE2D(_NormalMap);
                            SAMPLER(sampler_NormalMap);
                            TEXTURE2D(_Metal_Texture);
                            SAMPLER(sampler_Metal_Texture);

                            // Graph Includes
                            // GraphIncludes: <None>

                            // -- Property used by ScenePickingPass
                            #ifdef SCENEPICKINGPASS
                            float4 _SelectionID;
                            #endif

                            // -- Properties used by SceneSelectionPass
                            #ifdef SCENESELECTIONPASS
                            int _ObjectId;
                            int _PassValue;
                            #endif

                            // Graph Functions

                            void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                            {
                                //rotation matrix
                                Rotation = Rotation * (3.1415926f / 180.0f);
                                UV -= Center;
                                float s = sin(Rotation);
                                float c = cos(Rotation);

                                //center rotation matrix
                                float2x2 rMatrix = float2x2(c, -s, s, c);
                                rMatrix *= 0.5;
                                rMatrix += 0.5;
                                rMatrix = rMatrix * 2 - 1;

                                //multiply the UVs by the rotation matrix
                                UV.xy = mul(UV.xy, rMatrix);
                                UV += Center;

                                Out = UV;
                            }

                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                            {
                                Out = UV * Tiling + Offset;
                            }

                            // Custom interpolators pre vertex
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                            // Graph Vertex
                            struct VertexDescription
                            {
                                float3 Position;
                                float3 Normal;
                                float3 Tangent;
                            };

                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                            {
                                VertexDescription description = (VertexDescription)0;
                                description.Position = IN.ObjectSpacePosition;
                                description.Normal = IN.ObjectSpaceNormal;
                                description.Tangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Custom interpolators, pre surface
                            #ifdef FEATURES_GRAPH_VERTEX
                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                            {
                            return output;
                            }
                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                            #endif

                            // Graph Pixel
                            struct SurfaceDescription
                            {
                                float Alpha;
                                float AlphaClipThreshold;
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                UnityTexture2D _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
                                float2 _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2 = _RotationOffset;
                                float _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float = _Rotation;
                                float2 _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2;
                                Unity_Rotate_Degrees_float(IN.uv0.xy, _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2, _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float, _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2);
                                float2 _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2 = _Texture_Scale;
                                float2 _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2 = _Texture_Offset;
                                float2 _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2;
                                Unity_TilingAndOffset_float(_Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2, _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2, _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2, _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2);
                                float4 _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.tex, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.samplerstate, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2));
                                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_R_4_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.r;
                                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_G_5_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.g;
                                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_B_6_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.b;
                                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.a;
                                float _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float = _Alpha_Clip_Threshold;
                                surface.Alpha = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float;
                                surface.AlphaClipThreshold = _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs
                            #ifdef HAVE_VFX_MODIFICATION
                            #define VFX_SRP_ATTRIBUTES Attributes
                            #define VFX_SRP_VARYINGS Varyings
                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                            #endif
                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                            {
                                VertexDescriptionInputs output;
                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                output.ObjectSpaceNormal = input.normalOS;
                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                output.ObjectSpacePosition = input.positionOS;

                                return output;
                            }
                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                            #ifdef HAVE_VFX_MODIFICATION
                            #if VFX_USE_GRAPH_VALUES
                                uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                            #endif
                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                            #endif








                                #if UNITY_UV_STARTS_AT_TOP
                                #else
                                #endif


                                output.uv0 = input.texCoord0;
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                            #else
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                            #endif
                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                    return output;
                            }

                            // --------------------------------------------------
                            // Main

                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                            // --------------------------------------------------
                            // Visual Effect Vertex Invocations
                            #ifdef HAVE_VFX_MODIFICATION
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                            #endif

                            ENDHLSL
                            }
                            Pass
                            {
                                Name "DepthOnly"
                                Tags
                                {
                                    "LightMode" = "DepthOnly"
                                }

                                // Render State
                                Cull[_Cull]
                                ZTest LEqual
                                ZWrite On
                                ColorMask R

                                // Debug
                                // <None>

                                // --------------------------------------------------
                                // Pass

                                HLSLPROGRAM

                                // Pragmas
                                #pragma target 2.0
                                #pragma multi_compile_instancing
                                #pragma vertex vert
                                #pragma fragment frag

                                // Keywords
                                #pragma shader_feature_local_fragment _ _ALPHATEST_ON
                                #pragma multi_compile _ LOD_FADE_CROSSFADE
                                // GraphKeywords: <None>

                                // Defines

                                #define _NORMALMAP 1
                                #define _NORMAL_DROPOFF_TS 1
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define ATTRIBUTES_NEED_TEXCOORD0
                                #define VARYINGS_NEED_TEXCOORD0
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                #define USE_UNITY_CROSSFADE 1


                                // custom interpolator pre-include
                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                // Includes
                                #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

                                // --------------------------------------------------
                                // Structs and Packing

                                // custom interpolators pre packing
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                struct Attributes
                                {
                                     float3 positionOS : POSITION;
                                     float3 normalOS : NORMAL;
                                     float4 tangentOS : TANGENT;
                                     float4 uv0 : TEXCOORD0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float4 texCoord0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };
                                struct SurfaceDescriptionInputs
                                {
                                     float4 uv0;
                                };
                                struct VertexDescriptionInputs
                                {
                                     float3 ObjectSpaceNormal;
                                     float3 ObjectSpaceTangent;
                                     float3 ObjectSpacePosition;
                                };
                                struct PackedVaryings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float4 texCoord0 : INTERP0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };

                                PackedVaryings PackVaryings(Varyings input)
                                {
                                    PackedVaryings output;
                                    ZERO_INITIALIZE(PackedVaryings, output);
                                    output.positionCS = input.positionCS;
                                    output.texCoord0.xyzw = input.texCoord0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }

                                Varyings UnpackVaryings(PackedVaryings input)
                                {
                                    Varyings output;
                                    output.positionCS = input.positionCS;
                                    output.texCoord0 = input.texCoord0.xyzw;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }


                                // --------------------------------------------------
                                // Graph

                                // Graph Properties
                                CBUFFER_START(UnityPerMaterial)
                                float4 _Color;
                                float2 _Metal_Texture_Scale;
                                float4 _Main_Texture_TexelSize;
                                float2 _Metal_Texture_Offset;
                                float4 _Emissions_Mask_TexelSize;
                                float2 _Texture_Offset;
                                float4 _Shading_Color;
                                float _Cel_Shader_Offset;
                                float _Rim_Lighting;
                                float _Rim_Brightness;
                                float _Ambient_Self_Lighting;
                                float4 _NormalMap_TexelSize;
                                float _UseNormalMap;
                                float _Alpha_Clip_Threshold;
                                float _Cel_Ramp_Smoothness;
                                float2 _Texture_Scale;
                                float4 _Metal_Texture_TexelSize;
                                float _Smoothness;
                                float _Metallic;
                                float _Rotation;
                                float2 _RotationOffset;
                                CBUFFER_END


                                    // Object and Global properties
                                    SAMPLER(SamplerState_Linear_Repeat);
                                    TEXTURE2D(_Main_Texture);
                                    SAMPLER(sampler_Main_Texture);
                                    TEXTURE2D(_Emissions_Mask);
                                    SAMPLER(sampler_Emissions_Mask);
                                    TEXTURE2D(_NormalMap);
                                    SAMPLER(sampler_NormalMap);
                                    TEXTURE2D(_Metal_Texture);
                                    SAMPLER(sampler_Metal_Texture);

                                    // Graph Includes
                                    // GraphIncludes: <None>

                                    // -- Property used by ScenePickingPass
                                    #ifdef SCENEPICKINGPASS
                                    float4 _SelectionID;
                                    #endif

                                    // -- Properties used by SceneSelectionPass
                                    #ifdef SCENESELECTIONPASS
                                    int _ObjectId;
                                    int _PassValue;
                                    #endif

                                    // Graph Functions

                                    void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                                    {
                                        //rotation matrix
                                        Rotation = Rotation * (3.1415926f / 180.0f);
                                        UV -= Center;
                                        float s = sin(Rotation);
                                        float c = cos(Rotation);

                                        //center rotation matrix
                                        float2x2 rMatrix = float2x2(c, -s, s, c);
                                        rMatrix *= 0.5;
                                        rMatrix += 0.5;
                                        rMatrix = rMatrix * 2 - 1;

                                        //multiply the UVs by the rotation matrix
                                        UV.xy = mul(UV.xy, rMatrix);
                                        UV += Center;

                                        Out = UV;
                                    }

                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                    {
                                        Out = UV * Tiling + Offset;
                                    }

                                    // Custom interpolators pre vertex
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                    // Graph Vertex
                                    struct VertexDescription
                                    {
                                        float3 Position;
                                        float3 Normal;
                                        float3 Tangent;
                                    };

                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                    {
                                        VertexDescription description = (VertexDescription)0;
                                        description.Position = IN.ObjectSpacePosition;
                                        description.Normal = IN.ObjectSpaceNormal;
                                        description.Tangent = IN.ObjectSpaceTangent;
                                        return description;
                                    }

                                    // Custom interpolators, pre surface
                                    #ifdef FEATURES_GRAPH_VERTEX
                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                    {
                                    return output;
                                    }
                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                    #endif

                                    // Graph Pixel
                                    struct SurfaceDescription
                                    {
                                        float Alpha;
                                        float AlphaClipThreshold;
                                    };

                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                    {
                                        SurfaceDescription surface = (SurfaceDescription)0;
                                        UnityTexture2D _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
                                        float2 _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2 = _RotationOffset;
                                        float _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float = _Rotation;
                                        float2 _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2;
                                        Unity_Rotate_Degrees_float(IN.uv0.xy, _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2, _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float, _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2);
                                        float2 _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2 = _Texture_Scale;
                                        float2 _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2 = _Texture_Offset;
                                        float2 _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2;
                                        Unity_TilingAndOffset_float(_Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2, _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2, _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2, _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2);
                                        float4 _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.tex, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.samplerstate, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2));
                                        float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_R_4_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.r;
                                        float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_G_5_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.g;
                                        float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_B_6_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.b;
                                        float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.a;
                                        float _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float = _Alpha_Clip_Threshold;
                                        surface.Alpha = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float;
                                        surface.AlphaClipThreshold = _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float;
                                        return surface;
                                    }

                                    // --------------------------------------------------
                                    // Build Graph Inputs
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #define VFX_SRP_ATTRIBUTES Attributes
                                    #define VFX_SRP_VARYINGS Varyings
                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                    #endif
                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                    {
                                        VertexDescriptionInputs output;
                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                        output.ObjectSpaceNormal = input.normalOS;
                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                        output.ObjectSpacePosition = input.positionOS;

                                        return output;
                                    }
                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                    {
                                        SurfaceDescriptionInputs output;
                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                    #ifdef HAVE_VFX_MODIFICATION
                                    #if VFX_USE_GRAPH_VALUES
                                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                                    #endif
                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                    #endif








                                        #if UNITY_UV_STARTS_AT_TOP
                                        #else
                                        #endif


                                        output.uv0 = input.texCoord0;
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                    #else
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                    #endif
                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                            return output;
                                    }

                                    // --------------------------------------------------
                                    // Main

                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                    // --------------------------------------------------
                                    // Visual Effect Vertex Invocations
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                    #endif

                                    ENDHLSL
                                    }
                                    Pass
                                    {
                                        Name "DepthNormals"
                                        Tags
                                        {
                                            "LightMode" = "DepthNormals"
                                        }

                                        // Render State
                                        Cull[_Cull]
                                        ZTest LEqual
                                        ZWrite On

                                        // Debug
                                        // <None>

                                        // --------------------------------------------------
                                        // Pass

                                        HLSLPROGRAM

                                        // Pragmas
                                        #pragma target 2.0
                                        #pragma multi_compile_instancing
                                        #pragma vertex vert
                                        #pragma fragment frag

                                        // Keywords
                                        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
                                        #pragma multi_compile _ LOD_FADE_CROSSFADE
                                        // GraphKeywords: <None>

                                        // Defines

                                        #define _NORMALMAP 1
                                        #define _NORMAL_DROPOFF_TS 1
                                        #define ATTRIBUTES_NEED_NORMAL
                                        #define ATTRIBUTES_NEED_TANGENT
                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                        #define VARYINGS_NEED_NORMAL_WS
                                        #define VARYINGS_NEED_TANGENT_WS
                                        #define VARYINGS_NEED_TEXCOORD0
                                        #define FEATURES_GRAPH_VERTEX
                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                        #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                        #define USE_UNITY_CROSSFADE 1


                                        // custom interpolator pre-include
                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                        // Includes
                                        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
                                        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

                                        // --------------------------------------------------
                                        // Structs and Packing

                                        // custom interpolators pre packing
                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                        struct Attributes
                                        {
                                             float3 positionOS : POSITION;
                                             float3 normalOS : NORMAL;
                                             float4 tangentOS : TANGENT;
                                             float4 uv0 : TEXCOORD0;
                                             float4 uv1 : TEXCOORD1;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : INSTANCEID_SEMANTIC;
                                            #endif
                                        };
                                        struct Varyings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 normalWS;
                                             float4 tangentWS;
                                             float4 texCoord0;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };
                                        struct SurfaceDescriptionInputs
                                        {
                                             float3 TangentSpaceNormal;
                                             float4 uv0;
                                        };
                                        struct VertexDescriptionInputs
                                        {
                                             float3 ObjectSpaceNormal;
                                             float3 ObjectSpaceTangent;
                                             float3 ObjectSpacePosition;
                                        };
                                        struct PackedVaryings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float4 tangentWS : INTERP0;
                                             float4 texCoord0 : INTERP1;
                                             float3 normalWS : INTERP2;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };

                                        PackedVaryings PackVaryings(Varyings input)
                                        {
                                            PackedVaryings output;
                                            ZERO_INITIALIZE(PackedVaryings, output);
                                            output.positionCS = input.positionCS;
                                            output.tangentWS.xyzw = input.tangentWS;
                                            output.texCoord0.xyzw = input.texCoord0;
                                            output.normalWS.xyz = input.normalWS;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }

                                        Varyings UnpackVaryings(PackedVaryings input)
                                        {
                                            Varyings output;
                                            output.positionCS = input.positionCS;
                                            output.tangentWS = input.tangentWS.xyzw;
                                            output.texCoord0 = input.texCoord0.xyzw;
                                            output.normalWS = input.normalWS.xyz;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }


                                        // --------------------------------------------------
                                        // Graph

                                        // Graph Properties
                                        CBUFFER_START(UnityPerMaterial)
                                        float4 _Color;
                                        float2 _Metal_Texture_Scale;
                                        float4 _Main_Texture_TexelSize;
                                        float2 _Metal_Texture_Offset;
                                        float4 _Emissions_Mask_TexelSize;
                                        float2 _Texture_Offset;
                                        float4 _Shading_Color;
                                        float _Cel_Shader_Offset;
                                        float _Rim_Lighting;
                                        float _Rim_Brightness;
                                        float _Ambient_Self_Lighting;
                                        float4 _NormalMap_TexelSize;
                                        float _UseNormalMap;
                                        float _Alpha_Clip_Threshold;
                                        float _Cel_Ramp_Smoothness;
                                        float2 _Texture_Scale;
                                        float4 _Metal_Texture_TexelSize;
                                        float _Smoothness;
                                        float _Metallic;
                                        float _Rotation;
                                        float2 _RotationOffset;
                                        CBUFFER_END


                                            // Object and Global properties
                                            SAMPLER(SamplerState_Linear_Repeat);
                                            TEXTURE2D(_Main_Texture);
                                            SAMPLER(sampler_Main_Texture);
                                            TEXTURE2D(_Emissions_Mask);
                                            SAMPLER(sampler_Emissions_Mask);
                                            TEXTURE2D(_NormalMap);
                                            SAMPLER(sampler_NormalMap);
                                            TEXTURE2D(_Metal_Texture);
                                            SAMPLER(sampler_Metal_Texture);

                                            // Graph Includes
                                            // GraphIncludes: <None>

                                            // -- Property used by ScenePickingPass
                                            #ifdef SCENEPICKINGPASS
                                            float4 _SelectionID;
                                            #endif

                                            // -- Properties used by SceneSelectionPass
                                            #ifdef SCENESELECTIONPASS
                                            int _ObjectId;
                                            int _PassValue;
                                            #endif

                                            // Graph Functions

                                            void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                                            {
                                                //rotation matrix
                                                Rotation = Rotation * (3.1415926f / 180.0f);
                                                UV -= Center;
                                                float s = sin(Rotation);
                                                float c = cos(Rotation);

                                                //center rotation matrix
                                                float2x2 rMatrix = float2x2(c, -s, s, c);
                                                rMatrix *= 0.5;
                                                rMatrix += 0.5;
                                                rMatrix = rMatrix * 2 - 1;

                                                //multiply the UVs by the rotation matrix
                                                UV.xy = mul(UV.xy, rMatrix);
                                                UV += Center;

                                                Out = UV;
                                            }

                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                            {
                                                Out = UV * Tiling + Offset;
                                            }

                                            // Custom interpolators pre vertex
                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                            // Graph Vertex
                                            struct VertexDescription
                                            {
                                                float3 Position;
                                                float3 Normal;
                                                float3 Tangent;
                                            };

                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                            {
                                                VertexDescription description = (VertexDescription)0;
                                                description.Position = IN.ObjectSpacePosition;
                                                description.Normal = IN.ObjectSpaceNormal;
                                                description.Tangent = IN.ObjectSpaceTangent;
                                                return description;
                                            }

                                            // Custom interpolators, pre surface
                                            #ifdef FEATURES_GRAPH_VERTEX
                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                            {
                                            return output;
                                            }
                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                            #endif

                                            // Graph Pixel
                                            struct SurfaceDescription
                                            {
                                                float3 NormalTS;
                                                float Alpha;
                                                float AlphaClipThreshold;
                                            };

                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                            {
                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                UnityTexture2D _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
                                                float2 _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2 = _RotationOffset;
                                                float _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float = _Rotation;
                                                float2 _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2;
                                                Unity_Rotate_Degrees_float(IN.uv0.xy, _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2, _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float, _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2);
                                                float2 _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2 = _Texture_Scale;
                                                float2 _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2 = _Texture_Offset;
                                                float2 _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2;
                                                Unity_TilingAndOffset_float(_Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2, _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2, _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2, _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2);
                                                float4 _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.tex, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.samplerstate, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2));
                                                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_R_4_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.r;
                                                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_G_5_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.g;
                                                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_B_6_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.b;
                                                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.a;
                                                float _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float = _Alpha_Clip_Threshold;
                                                surface.NormalTS = IN.TangentSpaceNormal;
                                                surface.Alpha = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float;
                                                surface.AlphaClipThreshold = _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float;
                                                return surface;
                                            }

                                            // --------------------------------------------------
                                            // Build Graph Inputs
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #define VFX_SRP_ATTRIBUTES Attributes
                                            #define VFX_SRP_VARYINGS Varyings
                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                            #endif
                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                            {
                                                VertexDescriptionInputs output;
                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                output.ObjectSpaceNormal = input.normalOS;
                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                output.ObjectSpacePosition = input.positionOS;

                                                return output;
                                            }
                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                            {
                                                SurfaceDescriptionInputs output;
                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                            #ifdef HAVE_VFX_MODIFICATION
                                            #if VFX_USE_GRAPH_VALUES
                                                uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                                /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                                            #endif
                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                            #endif





                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);



                                                #if UNITY_UV_STARTS_AT_TOP
                                                #else
                                                #endif


                                                output.uv0 = input.texCoord0;
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                            #else
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                            #endif
                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                    return output;
                                            }

                                            // --------------------------------------------------
                                            // Main

                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                            // --------------------------------------------------
                                            // Visual Effect Vertex Invocations
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                            #endif

                                            ENDHLSL
                                            }
                                            Pass
                                            {
                                                Name "Meta"
                                                Tags
                                                {
                                                    "LightMode" = "Meta"
                                                }

                                                // Render State
                                                Cull Off

                                                // Debug
                                                // <None>

                                                // --------------------------------------------------
                                                // Pass

                                                HLSLPROGRAM

                                                // Pragmas
                                                #pragma target 2.0
                                                #pragma vertex vert
                                                #pragma fragment frag

                                                // Keywords
                                                #pragma shader_feature _ EDITOR_VISUALIZATION
                                                #pragma shader_feature_local_fragment _ _ALPHATEST_ON
                                                // GraphKeywords: <None>

                                                // Defines

                                                #define _NORMALMAP 1
                                                #define _NORMAL_DROPOFF_TS 1
                                                #define ATTRIBUTES_NEED_NORMAL
                                                #define ATTRIBUTES_NEED_TANGENT
                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                #define VARYINGS_NEED_POSITION_WS
                                                #define VARYINGS_NEED_NORMAL_WS
                                                #define VARYINGS_NEED_TEXCOORD0
                                                #define VARYINGS_NEED_TEXCOORD1
                                                #define VARYINGS_NEED_TEXCOORD2
                                                #define FEATURES_GRAPH_VERTEX
                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                #define SHADERPASS SHADERPASS_META
                                                #define _FOG_FRAGMENT 1


                                                // custom interpolator pre-include
                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                // Includes
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                // --------------------------------------------------
                                                // Structs and Packing

                                                // custom interpolators pre packing
                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                struct Attributes
                                                {
                                                     float3 positionOS : POSITION;
                                                     float3 normalOS : NORMAL;
                                                     float4 tangentOS : TANGENT;
                                                     float4 uv0 : TEXCOORD0;
                                                     float4 uv1 : TEXCOORD1;
                                                     float4 uv2 : TEXCOORD2;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                    #endif
                                                };
                                                struct Varyings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 positionWS;
                                                     float3 normalWS;
                                                     float4 texCoord0;
                                                     float4 texCoord1;
                                                     float4 texCoord2;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };
                                                struct SurfaceDescriptionInputs
                                                {
                                                     float3 WorldSpaceNormal;
                                                     float3 WorldSpaceViewDirection;
                                                     float3 ObjectSpacePosition;
                                                     float3 WorldSpacePosition;
                                                     float4 uv0;
                                                };
                                                struct VertexDescriptionInputs
                                                {
                                                     float3 ObjectSpaceNormal;
                                                     float3 ObjectSpaceTangent;
                                                     float3 ObjectSpacePosition;
                                                };
                                                struct PackedVaryings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float4 texCoord0 : INTERP0;
                                                     float4 texCoord1 : INTERP1;
                                                     float4 texCoord2 : INTERP2;
                                                     float3 positionWS : INTERP3;
                                                     float3 normalWS : INTERP4;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };

                                                PackedVaryings PackVaryings(Varyings input)
                                                {
                                                    PackedVaryings output;
                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                    output.positionCS = input.positionCS;
                                                    output.texCoord0.xyzw = input.texCoord0;
                                                    output.texCoord1.xyzw = input.texCoord1;
                                                    output.texCoord2.xyzw = input.texCoord2;
                                                    output.positionWS.xyz = input.positionWS;
                                                    output.normalWS.xyz = input.normalWS;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }

                                                Varyings UnpackVaryings(PackedVaryings input)
                                                {
                                                    Varyings output;
                                                    output.positionCS = input.positionCS;
                                                    output.texCoord0 = input.texCoord0.xyzw;
                                                    output.texCoord1 = input.texCoord1.xyzw;
                                                    output.texCoord2 = input.texCoord2.xyzw;
                                                    output.positionWS = input.positionWS.xyz;
                                                    output.normalWS = input.normalWS.xyz;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }


                                                // --------------------------------------------------
                                                // Graph

                                                // Graph Properties
                                                CBUFFER_START(UnityPerMaterial)
                                                float4 _Color;
                                                float2 _Metal_Texture_Scale;
                                                float4 _Main_Texture_TexelSize;
                                                float2 _Metal_Texture_Offset;
                                                float4 _Emissions_Mask_TexelSize;
                                                float2 _Texture_Offset;
                                                float4 _Shading_Color;
                                                float _Cel_Shader_Offset;
                                                float _Rim_Lighting;
                                                float _Rim_Brightness;
                                                float _Ambient_Self_Lighting;
                                                float4 _NormalMap_TexelSize;
                                                float _UseNormalMap;
                                                float _Alpha_Clip_Threshold;
                                                float _Cel_Ramp_Smoothness;
                                                float2 _Texture_Scale;
                                                float4 _Metal_Texture_TexelSize;
                                                float _Smoothness;
                                                float _Metallic;
                                                float _Rotation;
                                                float2 _RotationOffset;
                                                CBUFFER_END


                                                    // Object and Global properties
                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                    TEXTURE2D(_Main_Texture);
                                                    SAMPLER(sampler_Main_Texture);
                                                    TEXTURE2D(_Emissions_Mask);
                                                    SAMPLER(sampler_Emissions_Mask);
                                                    TEXTURE2D(_NormalMap);
                                                    SAMPLER(sampler_NormalMap);
                                                    TEXTURE2D(_Metal_Texture);
                                                    SAMPLER(sampler_Metal_Texture);

                                                    // Graph Includes
                                                    #include "../Cel.hlsl"

                                                    // -- Property used by ScenePickingPass
                                                    #ifdef SCENEPICKINGPASS
                                                    float4 _SelectionID;
                                                    #endif

                                                    // -- Properties used by SceneSelectionPass
                                                    #ifdef SCENESELECTIONPASS
                                                    int _ObjectId;
                                                    int _PassValue;
                                                    #endif

                                                    // Graph Functions

                                                    void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                                                    {
                                                        //rotation matrix
                                                        Rotation = Rotation * (3.1415926f / 180.0f);
                                                        UV -= Center;
                                                        float s = sin(Rotation);
                                                        float c = cos(Rotation);

                                                        //center rotation matrix
                                                        float2x2 rMatrix = float2x2(c, -s, s, c);
                                                        rMatrix *= 0.5;
                                                        rMatrix += 0.5;
                                                        rMatrix = rMatrix * 2 - 1;

                                                        //multiply the UVs by the rotation matrix
                                                        UV.xy = mul(UV.xy, rMatrix);
                                                        UV += Center;

                                                        Out = UV;
                                                    }

                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                    {
                                                        Out = UV * Tiling + Offset;
                                                    }

                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = A - B;
                                                    }

                                                    void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
                                                    {
                                                        Out = Predicate ? True : False;
                                                    }

                                                    void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                                                    {
                                                        Out = dot(A, B);
                                                    }

                                                    void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
                                                    {
                                                        Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
                                                    }

                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Step_float(float Edge, float In, out float Out)
                                                    {
                                                        Out = step(Edge, In);
                                                    }

                                                    void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    // Custom interpolators pre vertex
                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                    // Graph Vertex
                                                    struct VertexDescription
                                                    {
                                                        float3 Position;
                                                        float3 Normal;
                                                        float3 Tangent;
                                                    };

                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                    {
                                                        VertexDescription description = (VertexDescription)0;
                                                        description.Position = IN.ObjectSpacePosition;
                                                        description.Normal = IN.ObjectSpaceNormal;
                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                        return description;
                                                    }

                                                    // Custom interpolators, pre surface
                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                    {
                                                    return output;
                                                    }
                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                    #endif

                                                    // Graph Pixel
                                                    struct SurfaceDescription
                                                    {
                                                        float3 BaseColor;
                                                        float3 Emission;
                                                        float Alpha;
                                                        float AlphaClipThreshold;
                                                    };

                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                    {
                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                        UnityTexture2D _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
                                                        float2 _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2 = _RotationOffset;
                                                        float _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float = _Rotation;
                                                        float2 _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2;
                                                        Unity_Rotate_Degrees_float(IN.uv0.xy, _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2, _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float, _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2);
                                                        float2 _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2 = _Texture_Scale;
                                                        float2 _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2 = _Texture_Offset;
                                                        float2 _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2;
                                                        Unity_TilingAndOffset_float(_Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2, _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2, _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2, _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2);
                                                        float4 _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.tex, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.samplerstate, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2));
                                                        float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_R_4_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.r;
                                                        float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_G_5_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.g;
                                                        float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_B_6_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.b;
                                                        float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.a;
                                                        float4 _Property_fdab52b7937644c6bd147c5450c3f251_Out_0_Vector4 = _Color;
                                                        float4 _Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4;
                                                        Unity_Multiply_float4_float4(_SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4, _Property_fdab52b7937644c6bd147c5450c3f251_Out_0_Vector4, _Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4);
                                                        UnityTexture2D _Property_2a814b19185d49e0b94d6605f815fc22_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Emissions_Mask);
                                                        float4 _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2a814b19185d49e0b94d6605f815fc22_Out_0_Texture2D.tex, _Property_2a814b19185d49e0b94d6605f815fc22_Out_0_Texture2D.samplerstate, _Property_2a814b19185d49e0b94d6605f815fc22_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                                                        float _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_R_4_Float = _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4.r;
                                                        float _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_G_5_Float = _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4.g;
                                                        float _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_B_6_Float = _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4.b;
                                                        float _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_A_7_Float = _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4.a;
                                                        float4 _Multiply_08eeabd84e22476193f424c2d7c85045_Out_2_Vector4;
                                                        Unity_Multiply_float4_float4(_Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4, (_SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_R_4_Float.xxxx), _Multiply_08eeabd84e22476193f424c2d7c85045_Out_2_Vector4);
                                                        float _Property_f4350f6cd94f4ff688723b2601758647_Out_0_Boolean = _UseNormalMap;
                                                        UnityTexture2D _Property_2935e6b933c9464c9a226e3939202d3f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
                                                        float4 _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2935e6b933c9464c9a226e3939202d3f_Out_0_Texture2D.tex, _Property_2935e6b933c9464c9a226e3939202d3f_Out_0_Texture2D.samplerstate, _Property_2935e6b933c9464c9a226e3939202d3f_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                                                        float _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_R_4_Float = _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4.r;
                                                        float _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_G_5_Float = _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4.g;
                                                        float _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_B_6_Float = _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4.b;
                                                        float _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_A_7_Float = _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4.a;
                                                        float4 _Subtract_97b8413d701a46f89b6a6a50965c849b_Out_2_Vector4;
                                                        Unity_Subtract_float4(_SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4, float4(0.5, 0.5, 0.5, 0.5), _Subtract_97b8413d701a46f89b6a6a50965c849b_Out_2_Vector4);
                                                        float4 _Multiply_c404d82a7afb45eea38c0f2f8913b3a2_Out_2_Vector4;
                                                        Unity_Multiply_float4_float4(_Subtract_97b8413d701a46f89b6a6a50965c849b_Out_2_Vector4, float4(2, 2, 2, 2), _Multiply_c404d82a7afb45eea38c0f2f8913b3a2_Out_2_Vector4);
                                                        float3 _Branch_f5eae9fa1f90448eabeacd6c1897a242_Out_3_Vector3;
                                                        Unity_Branch_float3(_Property_f4350f6cd94f4ff688723b2601758647_Out_0_Boolean, (_Multiply_c404d82a7afb45eea38c0f2f8913b3a2_Out_2_Vector4.xyz), IN.WorldSpaceNormal, _Branch_f5eae9fa1f90448eabeacd6c1897a242_Out_3_Vector3);
                                                        float _Property_5c3b0e65e43446d3ae6a44d69cece6ed_Out_0_Float = _Cel_Ramp_Smoothness;
                                                        float4 _Property_3bfe113ecee2425dbb2ce8c43d76f557_Out_0_Vector4 = _Shading_Color;
                                                        float _Property_0562fc1a3d1841be83d39c63b4485cee_Out_0_Float = _Cel_Shader_Offset;
                                                        float Slider_8d27041afd1d4a0c9c60c067176a44c9 = 0.5;
                                                        float _Property_cbc4f53f5a8e4226b87bb2246a5ed158_Out_0_Float = _Ambient_Self_Lighting;
                                                        float3 _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_ToonRampOutput_0_Vector3;
                                                        float3 _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_Direction_7_Vector3;
                                                        CelShading_float(_Branch_f5eae9fa1f90448eabeacd6c1897a242_Out_3_Vector3, _Property_5c3b0e65e43446d3ae6a44d69cece6ed_Out_0_Float, IN.ObjectSpacePosition, IN.WorldSpacePosition, (_Property_3bfe113ecee2425dbb2ce8c43d76f557_Out_0_Vector4.xyz), _Property_0562fc1a3d1841be83d39c63b4485cee_Out_0_Float, Slider_8d27041afd1d4a0c9c60c067176a44c9, _Property_cbc4f53f5a8e4226b87bb2246a5ed158_Out_0_Float, _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_ToonRampOutput_0_Vector3, _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_Direction_7_Vector3);
                                                        float _DotProduct_869fe8cb72874c72aabcc111591a62cd_Out_2_Float;
                                                        Unity_DotProduct_float3(_Branch_f5eae9fa1f90448eabeacd6c1897a242_Out_3_Vector3, _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_Direction_7_Vector3, _DotProduct_869fe8cb72874c72aabcc111591a62cd_Out_2_Float);
                                                        float _Property_bd8d78e287724bebbeb518d7e1ab0c20_Out_0_Float = _Rim_Lighting;
                                                        float _FresnelEffect_f452c68b8d004619bb2fa547d94e8942_Out_3_Float;
                                                        Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_bd8d78e287724bebbeb518d7e1ab0c20_Out_0_Float, _FresnelEffect_f452c68b8d004619bb2fa547d94e8942_Out_3_Float);
                                                        float _Multiply_500bfd19683e48cbbfd9139fcb7dc218_Out_2_Float;
                                                        Unity_Multiply_float_float(_DotProduct_869fe8cb72874c72aabcc111591a62cd_Out_2_Float, _FresnelEffect_f452c68b8d004619bb2fa547d94e8942_Out_3_Float, _Multiply_500bfd19683e48cbbfd9139fcb7dc218_Out_2_Float);
                                                        float _Step_48bb4a882f094cbc9be0e421634c6929_Out_2_Float;
                                                        Unity_Step_float(float(0.5), _Multiply_500bfd19683e48cbbfd9139fcb7dc218_Out_2_Float, _Step_48bb4a882f094cbc9be0e421634c6929_Out_2_Float);
                                                        float4 _Multiply_1950ac11d2144717b01dc351ee1c8986_Out_2_Vector4;
                                                        Unity_Multiply_float4_float4(_Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4, (_Step_48bb4a882f094cbc9be0e421634c6929_Out_2_Float.xxxx), _Multiply_1950ac11d2144717b01dc351ee1c8986_Out_2_Vector4);
                                                        float _Property_c341dd541b3a425d9d9823d7984f6bf5_Out_0_Float = _Rim_Brightness;
                                                        float4 _Multiply_91b3bc779fce42e0af22ce8684a3e501_Out_2_Vector4;
                                                        Unity_Multiply_float4_float4(_Multiply_1950ac11d2144717b01dc351ee1c8986_Out_2_Vector4, (_Property_c341dd541b3a425d9d9823d7984f6bf5_Out_0_Float.xxxx), _Multiply_91b3bc779fce42e0af22ce8684a3e501_Out_2_Vector4);
                                                        float3 _Multiply_55211470d6b746f5b5fecb73a5dea81b_Out_2_Vector3;
                                                        Unity_Multiply_float3_float3((_Multiply_91b3bc779fce42e0af22ce8684a3e501_Out_2_Vector4.xyz), _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_ToonRampOutput_0_Vector3, _Multiply_55211470d6b746f5b5fecb73a5dea81b_Out_2_Vector3);
                                                        float3 _Multiply_6208b7b8f0c543e78a2446e5fc4eb226_Out_2_Vector3;
                                                        Unity_Multiply_float3_float3((_Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4.xyz), _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_ToonRampOutput_0_Vector3, _Multiply_6208b7b8f0c543e78a2446e5fc4eb226_Out_2_Vector3);
                                                        float3 _Add_6c8423e60dfd4875874ca92d4f743b9e_Out_2_Vector3;
                                                        Unity_Add_float3(_Multiply_55211470d6b746f5b5fecb73a5dea81b_Out_2_Vector3, _Multiply_6208b7b8f0c543e78a2446e5fc4eb226_Out_2_Vector3, _Add_6c8423e60dfd4875874ca92d4f743b9e_Out_2_Vector3);
                                                        float3 _Add_e9066678904e4fd590e41227b2822728_Out_2_Vector3;
                                                        Unity_Add_float3((_Multiply_08eeabd84e22476193f424c2d7c85045_Out_2_Vector4.xyz), _Add_6c8423e60dfd4875874ca92d4f743b9e_Out_2_Vector3, _Add_e9066678904e4fd590e41227b2822728_Out_2_Vector3);
                                                        float _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float = _Alpha_Clip_Threshold;
                                                        surface.BaseColor = _Add_e9066678904e4fd590e41227b2822728_Out_2_Vector3;
                                                        surface.Emission = _Add_e9066678904e4fd590e41227b2822728_Out_2_Vector3;
                                                        surface.Alpha = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float;
                                                        surface.AlphaClipThreshold = _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float;
                                                        return surface;
                                                    }

                                                    // --------------------------------------------------
                                                    // Build Graph Inputs
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                    #define VFX_SRP_VARYINGS Varyings
                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                    #endif
                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                    {
                                                        VertexDescriptionInputs output;
                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                        output.ObjectSpaceNormal = input.normalOS;
                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                        output.ObjectSpacePosition = input.positionOS;

                                                        return output;
                                                    }
                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                    {
                                                        SurfaceDescriptionInputs output;
                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #if VFX_USE_GRAPH_VALUES
                                                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                                                    #endif
                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                    #endif



                                                        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                        float3 unnormalizedNormalWS = input.normalWS;
                                                        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                                        output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                                                        output.WorldSpacePosition = input.positionWS;
                                                        output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);

                                                        #if UNITY_UV_STARTS_AT_TOP
                                                        #else
                                                        #endif


                                                        output.uv0 = input.texCoord0;
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                    #else
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                    #endif
                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                            return output;
                                                    }

                                                    // --------------------------------------------------
                                                    // Main

                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                    // --------------------------------------------------
                                                    // Visual Effect Vertex Invocations
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                    #endif

                                                    ENDHLSL
                                                    }
                                                    Pass
                                                    {
                                                        Name "SceneSelectionPass"
                                                        Tags
                                                        {
                                                            "LightMode" = "SceneSelectionPass"
                                                        }

                                                        // Render State
                                                        Cull Off

                                                        // Debug
                                                        // <None>

                                                        // --------------------------------------------------
                                                        // Pass

                                                        HLSLPROGRAM

                                                        // Pragmas
                                                        #pragma target 2.0
                                                        #pragma vertex vert
                                                        #pragma fragment frag

                                                        // Keywords
                                                        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
                                                        // GraphKeywords: <None>

                                                        // Defines

                                                        #define _NORMALMAP 1
                                                        #define _NORMAL_DROPOFF_TS 1
                                                        #define ATTRIBUTES_NEED_NORMAL
                                                        #define ATTRIBUTES_NEED_TANGENT
                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                        #define VARYINGS_NEED_TEXCOORD0
                                                        #define FEATURES_GRAPH_VERTEX
                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                        #define SCENESELECTIONPASS 1
                                                        #define ALPHA_CLIP_THRESHOLD 1


                                                        // custom interpolator pre-include
                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                        // Includes
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                        // --------------------------------------------------
                                                        // Structs and Packing

                                                        // custom interpolators pre packing
                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                        struct Attributes
                                                        {
                                                             float3 positionOS : POSITION;
                                                             float3 normalOS : NORMAL;
                                                             float4 tangentOS : TANGENT;
                                                             float4 uv0 : TEXCOORD0;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct Varyings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float4 texCoord0;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct SurfaceDescriptionInputs
                                                        {
                                                             float4 uv0;
                                                        };
                                                        struct VertexDescriptionInputs
                                                        {
                                                             float3 ObjectSpaceNormal;
                                                             float3 ObjectSpaceTangent;
                                                             float3 ObjectSpacePosition;
                                                        };
                                                        struct PackedVaryings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float4 texCoord0 : INTERP0;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };

                                                        PackedVaryings PackVaryings(Varyings input)
                                                        {
                                                            PackedVaryings output;
                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                            output.positionCS = input.positionCS;
                                                            output.texCoord0.xyzw = input.texCoord0;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }

                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                        {
                                                            Varyings output;
                                                            output.positionCS = input.positionCS;
                                                            output.texCoord0 = input.texCoord0.xyzw;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }


                                                        // --------------------------------------------------
                                                        // Graph

                                                        // Graph Properties
                                                        CBUFFER_START(UnityPerMaterial)
                                                        float4 _Color;
                                                        float2 _Metal_Texture_Scale;
                                                        float4 _Main_Texture_TexelSize;
                                                        float2 _Metal_Texture_Offset;
                                                        float4 _Emissions_Mask_TexelSize;
                                                        float2 _Texture_Offset;
                                                        float4 _Shading_Color;
                                                        float _Cel_Shader_Offset;
                                                        float _Rim_Lighting;
                                                        float _Rim_Brightness;
                                                        float _Ambient_Self_Lighting;
                                                        float4 _NormalMap_TexelSize;
                                                        float _UseNormalMap;
                                                        float _Alpha_Clip_Threshold;
                                                        float _Cel_Ramp_Smoothness;
                                                        float2 _Texture_Scale;
                                                        float4 _Metal_Texture_TexelSize;
                                                        float _Smoothness;
                                                        float _Metallic;
                                                        float _Rotation;
                                                        float2 _RotationOffset;
                                                        CBUFFER_END


                                                            // Object and Global properties
                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                            TEXTURE2D(_Main_Texture);
                                                            SAMPLER(sampler_Main_Texture);
                                                            TEXTURE2D(_Emissions_Mask);
                                                            SAMPLER(sampler_Emissions_Mask);
                                                            TEXTURE2D(_NormalMap);
                                                            SAMPLER(sampler_NormalMap);
                                                            TEXTURE2D(_Metal_Texture);
                                                            SAMPLER(sampler_Metal_Texture);

                                                            // Graph Includes
                                                            // GraphIncludes: <None>

                                                            // -- Property used by ScenePickingPass
                                                            #ifdef SCENEPICKINGPASS
                                                            float4 _SelectionID;
                                                            #endif

                                                            // -- Properties used by SceneSelectionPass
                                                            #ifdef SCENESELECTIONPASS
                                                            int _ObjectId;
                                                            int _PassValue;
                                                            #endif

                                                            // Graph Functions

                                                            void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                                                            {
                                                                //rotation matrix
                                                                Rotation = Rotation * (3.1415926f / 180.0f);
                                                                UV -= Center;
                                                                float s = sin(Rotation);
                                                                float c = cos(Rotation);

                                                                //center rotation matrix
                                                                float2x2 rMatrix = float2x2(c, -s, s, c);
                                                                rMatrix *= 0.5;
                                                                rMatrix += 0.5;
                                                                rMatrix = rMatrix * 2 - 1;

                                                                //multiply the UVs by the rotation matrix
                                                                UV.xy = mul(UV.xy, rMatrix);
                                                                UV += Center;

                                                                Out = UV;
                                                            }

                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                            {
                                                                Out = UV * Tiling + Offset;
                                                            }

                                                            // Custom interpolators pre vertex
                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                            // Graph Vertex
                                                            struct VertexDescription
                                                            {
                                                                float3 Position;
                                                                float3 Normal;
                                                                float3 Tangent;
                                                            };

                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                            {
                                                                VertexDescription description = (VertexDescription)0;
                                                                description.Position = IN.ObjectSpacePosition;
                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                return description;
                                                            }

                                                            // Custom interpolators, pre surface
                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                            {
                                                            return output;
                                                            }
                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                            #endif

                                                            // Graph Pixel
                                                            struct SurfaceDescription
                                                            {
                                                                float Alpha;
                                                                float AlphaClipThreshold;
                                                            };

                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                            {
                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                UnityTexture2D _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
                                                                float2 _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2 = _RotationOffset;
                                                                float _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float = _Rotation;
                                                                float2 _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2;
                                                                Unity_Rotate_Degrees_float(IN.uv0.xy, _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2, _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float, _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2);
                                                                float2 _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2 = _Texture_Scale;
                                                                float2 _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2 = _Texture_Offset;
                                                                float2 _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2;
                                                                Unity_TilingAndOffset_float(_Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2, _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2, _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2, _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2);
                                                                float4 _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.tex, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.samplerstate, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2));
                                                                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_R_4_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.r;
                                                                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_G_5_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.g;
                                                                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_B_6_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.b;
                                                                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.a;
                                                                float _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float = _Alpha_Clip_Threshold;
                                                                surface.Alpha = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float;
                                                                surface.AlphaClipThreshold = _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float;
                                                                return surface;
                                                            }

                                                            // --------------------------------------------------
                                                            // Build Graph Inputs
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                            #define VFX_SRP_VARYINGS Varyings
                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                            #endif
                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                            {
                                                                VertexDescriptionInputs output;
                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                output.ObjectSpacePosition = input.positionOS;

                                                                return output;
                                                            }
                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                            {
                                                                SurfaceDescriptionInputs output;
                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #if VFX_USE_GRAPH_VALUES
                                                                uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                                                /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                                                            #endif
                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                            #endif








                                                                #if UNITY_UV_STARTS_AT_TOP
                                                                #else
                                                                #endif


                                                                output.uv0 = input.texCoord0;
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                            #else
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                            #endif
                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                    return output;
                                                            }

                                                            // --------------------------------------------------
                                                            // Main

                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                            // --------------------------------------------------
                                                            // Visual Effect Vertex Invocations
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                            #endif

                                                            ENDHLSL
                                                            }
                                                            Pass
                                                            {
                                                                Name "ScenePickingPass"
                                                                Tags
                                                                {
                                                                    "LightMode" = "Picking"
                                                                }

                                                                // Render State
                                                                Cull[_Cull]

                                                                // Debug
                                                                // <None>

                                                                // --------------------------------------------------
                                                                // Pass

                                                                HLSLPROGRAM

                                                                // Pragmas
                                                                #pragma target 2.0
                                                                #pragma vertex vert
                                                                #pragma fragment frag

                                                                // Keywords
                                                                #pragma shader_feature_local_fragment _ _ALPHATEST_ON
                                                                // GraphKeywords: <None>

                                                                // Defines

                                                                #define _NORMALMAP 1
                                                                #define _NORMAL_DROPOFF_TS 1
                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                #define FEATURES_GRAPH_VERTEX
                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                #define SCENEPICKINGPASS 1
                                                                #define ALPHA_CLIP_THRESHOLD 1


                                                                // custom interpolator pre-include
                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                // Includes
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                // --------------------------------------------------
                                                                // Structs and Packing

                                                                // custom interpolators pre packing
                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                struct Attributes
                                                                {
                                                                     float3 positionOS : POSITION;
                                                                     float3 normalOS : NORMAL;
                                                                     float4 tangentOS : TANGENT;
                                                                     float4 uv0 : TEXCOORD0;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct Varyings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float4 texCoord0;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct SurfaceDescriptionInputs
                                                                {
                                                                     float4 uv0;
                                                                };
                                                                struct VertexDescriptionInputs
                                                                {
                                                                     float3 ObjectSpaceNormal;
                                                                     float3 ObjectSpaceTangent;
                                                                     float3 ObjectSpacePosition;
                                                                };
                                                                struct PackedVaryings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float4 texCoord0 : INTERP0;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };

                                                                PackedVaryings PackVaryings(Varyings input)
                                                                {
                                                                    PackedVaryings output;
                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                    output.positionCS = input.positionCS;
                                                                    output.texCoord0.xyzw = input.texCoord0;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }

                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                {
                                                                    Varyings output;
                                                                    output.positionCS = input.positionCS;
                                                                    output.texCoord0 = input.texCoord0.xyzw;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }


                                                                // --------------------------------------------------
                                                                // Graph

                                                                // Graph Properties
                                                                CBUFFER_START(UnityPerMaterial)
                                                                float4 _Color;
                                                                float2 _Metal_Texture_Scale;
                                                                float4 _Main_Texture_TexelSize;
                                                                float2 _Metal_Texture_Offset;
                                                                float4 _Emissions_Mask_TexelSize;
                                                                float2 _Texture_Offset;
                                                                float4 _Shading_Color;
                                                                float _Cel_Shader_Offset;
                                                                float _Rim_Lighting;
                                                                float _Rim_Brightness;
                                                                float _Ambient_Self_Lighting;
                                                                float4 _NormalMap_TexelSize;
                                                                float _UseNormalMap;
                                                                float _Alpha_Clip_Threshold;
                                                                float _Cel_Ramp_Smoothness;
                                                                float2 _Texture_Scale;
                                                                float4 _Metal_Texture_TexelSize;
                                                                float _Smoothness;
                                                                float _Metallic;
                                                                float _Rotation;
                                                                float2 _RotationOffset;
                                                                CBUFFER_END


                                                                    // Object and Global properties
                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                    TEXTURE2D(_Main_Texture);
                                                                    SAMPLER(sampler_Main_Texture);
                                                                    TEXTURE2D(_Emissions_Mask);
                                                                    SAMPLER(sampler_Emissions_Mask);
                                                                    TEXTURE2D(_NormalMap);
                                                                    SAMPLER(sampler_NormalMap);
                                                                    TEXTURE2D(_Metal_Texture);
                                                                    SAMPLER(sampler_Metal_Texture);

                                                                    // Graph Includes
                                                                    // GraphIncludes: <None>

                                                                    // -- Property used by ScenePickingPass
                                                                    #ifdef SCENEPICKINGPASS
                                                                    float4 _SelectionID;
                                                                    #endif

                                                                    // -- Properties used by SceneSelectionPass
                                                                    #ifdef SCENESELECTIONPASS
                                                                    int _ObjectId;
                                                                    int _PassValue;
                                                                    #endif

                                                                    // Graph Functions

                                                                    void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                                                                    {
                                                                        //rotation matrix
                                                                        Rotation = Rotation * (3.1415926f / 180.0f);
                                                                        UV -= Center;
                                                                        float s = sin(Rotation);
                                                                        float c = cos(Rotation);

                                                                        //center rotation matrix
                                                                        float2x2 rMatrix = float2x2(c, -s, s, c);
                                                                        rMatrix *= 0.5;
                                                                        rMatrix += 0.5;
                                                                        rMatrix = rMatrix * 2 - 1;

                                                                        //multiply the UVs by the rotation matrix
                                                                        UV.xy = mul(UV.xy, rMatrix);
                                                                        UV += Center;

                                                                        Out = UV;
                                                                    }

                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                    {
                                                                        Out = UV * Tiling + Offset;
                                                                    }

                                                                    // Custom interpolators pre vertex
                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                    // Graph Vertex
                                                                    struct VertexDescription
                                                                    {
                                                                        float3 Position;
                                                                        float3 Normal;
                                                                        float3 Tangent;
                                                                    };

                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                    {
                                                                        VertexDescription description = (VertexDescription)0;
                                                                        description.Position = IN.ObjectSpacePosition;
                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                        return description;
                                                                    }

                                                                    // Custom interpolators, pre surface
                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                    {
                                                                    return output;
                                                                    }
                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                    #endif

                                                                    // Graph Pixel
                                                                    struct SurfaceDescription
                                                                    {
                                                                        float Alpha;
                                                                        float AlphaClipThreshold;
                                                                    };

                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                    {
                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                        UnityTexture2D _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
                                                                        float2 _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2 = _RotationOffset;
                                                                        float _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float = _Rotation;
                                                                        float2 _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2;
                                                                        Unity_Rotate_Degrees_float(IN.uv0.xy, _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2, _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float, _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2);
                                                                        float2 _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2 = _Texture_Scale;
                                                                        float2 _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2 = _Texture_Offset;
                                                                        float2 _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2;
                                                                        Unity_TilingAndOffset_float(_Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2, _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2, _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2, _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2);
                                                                        float4 _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.tex, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.samplerstate, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2));
                                                                        float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_R_4_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.r;
                                                                        float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_G_5_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.g;
                                                                        float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_B_6_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.b;
                                                                        float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.a;
                                                                        float _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float = _Alpha_Clip_Threshold;
                                                                        surface.Alpha = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float;
                                                                        surface.AlphaClipThreshold = _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float;
                                                                        return surface;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Build Graph Inputs
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                    #endif
                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                    {
                                                                        VertexDescriptionInputs output;
                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                        output.ObjectSpacePosition = input.positionOS;

                                                                        return output;
                                                                    }
                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                    {
                                                                        SurfaceDescriptionInputs output;
                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #if VFX_USE_GRAPH_VALUES
                                                                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                                                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                                                                    #endif
                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                    #endif








                                                                        #if UNITY_UV_STARTS_AT_TOP
                                                                        #else
                                                                        #endif


                                                                        output.uv0 = input.texCoord0;
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                    #else
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                    #endif
                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                            return output;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Main

                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                    // --------------------------------------------------
                                                                    // Visual Effect Vertex Invocations
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                    #endif

                                                                    ENDHLSL
                                                                    }
                                                                    Pass
                                                                    {
                                                                        Name "Universal 2D"
                                                                        Tags
                                                                        {
                                                                            "LightMode" = "Universal2D"
                                                                        }

                                                                        // Render State
                                                                        Cull[_Cull]
                                                                        Blend[_SrcBlend][_DstBlend]
                                                                        ZTest[_ZTest]
                                                                        ZWrite[_ZWrite]

                                                                        // Debug
                                                                        // <None>

                                                                        // --------------------------------------------------
                                                                        // Pass

                                                                        HLSLPROGRAM

                                                                        // Pragmas
                                                                        #pragma target 2.0
                                                                        #pragma vertex vert
                                                                        #pragma fragment frag

                                                                        // Keywords
                                                                        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
                                                                        // GraphKeywords: <None>

                                                                        // Defines

                                                                        #define _NORMALMAP 1
                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                        #define FEATURES_GRAPH_VERTEX
                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                        #define SHADERPASS SHADERPASS_2D


                                                                        // custom interpolator pre-include
                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                        // Includes
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                        // --------------------------------------------------
                                                                        // Structs and Packing

                                                                        // custom interpolators pre packing
                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                        struct Attributes
                                                                        {
                                                                             float3 positionOS : POSITION;
                                                                             float3 normalOS : NORMAL;
                                                                             float4 tangentOS : TANGENT;
                                                                             float4 uv0 : TEXCOORD0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct Varyings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float3 positionWS;
                                                                             float3 normalWS;
                                                                             float4 texCoord0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct SurfaceDescriptionInputs
                                                                        {
                                                                             float3 WorldSpaceNormal;
                                                                             float3 WorldSpaceViewDirection;
                                                                             float3 ObjectSpacePosition;
                                                                             float3 WorldSpacePosition;
                                                                             float4 uv0;
                                                                        };
                                                                        struct VertexDescriptionInputs
                                                                        {
                                                                             float3 ObjectSpaceNormal;
                                                                             float3 ObjectSpaceTangent;
                                                                             float3 ObjectSpacePosition;
                                                                        };
                                                                        struct PackedVaryings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float4 texCoord0 : INTERP0;
                                                                             float3 positionWS : INTERP1;
                                                                             float3 normalWS : INTERP2;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };

                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                        {
                                                                            PackedVaryings output;
                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                            output.positionCS = input.positionCS;
                                                                            output.texCoord0.xyzw = input.texCoord0;
                                                                            output.positionWS.xyz = input.positionWS;
                                                                            output.normalWS.xyz = input.normalWS;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }

                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                        {
                                                                            Varyings output;
                                                                            output.positionCS = input.positionCS;
                                                                            output.texCoord0 = input.texCoord0.xyzw;
                                                                            output.positionWS = input.positionWS.xyz;
                                                                            output.normalWS = input.normalWS.xyz;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }


                                                                        // --------------------------------------------------
                                                                        // Graph

                                                                        // Graph Properties
                                                                        CBUFFER_START(UnityPerMaterial)
                                                                        float4 _Color;
                                                                        float2 _Metal_Texture_Scale;
                                                                        float4 _Main_Texture_TexelSize;
                                                                        float2 _Metal_Texture_Offset;
                                                                        float4 _Emissions_Mask_TexelSize;
                                                                        float2 _Texture_Offset;
                                                                        float4 _Shading_Color;
                                                                        float _Cel_Shader_Offset;
                                                                        float _Rim_Lighting;
                                                                        float _Rim_Brightness;
                                                                        float _Ambient_Self_Lighting;
                                                                        float4 _NormalMap_TexelSize;
                                                                        float _UseNormalMap;
                                                                        float _Alpha_Clip_Threshold;
                                                                        float _Cel_Ramp_Smoothness;
                                                                        float2 _Texture_Scale;
                                                                        float4 _Metal_Texture_TexelSize;
                                                                        float _Smoothness;
                                                                        float _Metallic;
                                                                        float _Rotation;
                                                                        float2 _RotationOffset;
                                                                        CBUFFER_END


                                                                            // Object and Global properties
                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                            TEXTURE2D(_Main_Texture);
                                                                            SAMPLER(sampler_Main_Texture);
                                                                            TEXTURE2D(_Emissions_Mask);
                                                                            SAMPLER(sampler_Emissions_Mask);
                                                                            TEXTURE2D(_NormalMap);
                                                                            SAMPLER(sampler_NormalMap);
                                                                            TEXTURE2D(_Metal_Texture);
                                                                            SAMPLER(sampler_Metal_Texture);

                                                                            // Graph Includes
                                                                            #include "../Cel.hlsl"

                                                                            // -- Property used by ScenePickingPass
                                                                            #ifdef SCENEPICKINGPASS
                                                                            float4 _SelectionID;
                                                                            #endif

                                                                            // -- Properties used by SceneSelectionPass
                                                                            #ifdef SCENESELECTIONPASS
                                                                            int _ObjectId;
                                                                            int _PassValue;
                                                                            #endif

                                                                            // Graph Functions

                                                                            void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                                                                            {
                                                                                //rotation matrix
                                                                                Rotation = Rotation * (3.1415926f / 180.0f);
                                                                                UV -= Center;
                                                                                float s = sin(Rotation);
                                                                                float c = cos(Rotation);

                                                                                //center rotation matrix
                                                                                float2x2 rMatrix = float2x2(c, -s, s, c);
                                                                                rMatrix *= 0.5;
                                                                                rMatrix += 0.5;
                                                                                rMatrix = rMatrix * 2 - 1;

                                                                                //multiply the UVs by the rotation matrix
                                                                                UV.xy = mul(UV.xy, rMatrix);
                                                                                UV += Center;

                                                                                Out = UV;
                                                                            }

                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                            {
                                                                                Out = UV * Tiling + Offset;
                                                                            }

                                                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
                                                                            {
                                                                                Out = A - B;
                                                                            }

                                                                            void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
                                                                            {
                                                                                Out = Predicate ? True : False;
                                                                            }

                                                                            void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                                                                            {
                                                                                Out = dot(A, B);
                                                                            }

                                                                            void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
                                                                            {
                                                                                Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
                                                                            }

                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_Step_float(float Edge, float In, out float Out)
                                                                            {
                                                                                Out = step(Edge, In);
                                                                            }

                                                                            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                                            {
                                                                                Out = A + B;
                                                                            }

                                                                            // Custom interpolators pre vertex
                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                            // Graph Vertex
                                                                            struct VertexDescription
                                                                            {
                                                                                float3 Position;
                                                                                float3 Normal;
                                                                                float3 Tangent;
                                                                            };

                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                            {
                                                                                VertexDescription description = (VertexDescription)0;
                                                                                description.Position = IN.ObjectSpacePosition;
                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                return description;
                                                                            }

                                                                            // Custom interpolators, pre surface
                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                            {
                                                                            return output;
                                                                            }
                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                            #endif

                                                                            // Graph Pixel
                                                                            struct SurfaceDescription
                                                                            {
                                                                                float3 BaseColor;
                                                                                float Alpha;
                                                                                float AlphaClipThreshold;
                                                                            };

                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                            {
                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                UnityTexture2D _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
                                                                                float2 _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2 = _RotationOffset;
                                                                                float _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float = _Rotation;
                                                                                float2 _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2;
                                                                                Unity_Rotate_Degrees_float(IN.uv0.xy, _Property_3129c06e513b4c25a5160841c082296e_Out_0_Vector2, _Property_241833f0c1f743a49ce28fe45f03dca5_Out_0_Float, _Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2);
                                                                                float2 _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2 = _Texture_Scale;
                                                                                float2 _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2 = _Texture_Offset;
                                                                                float2 _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2;
                                                                                Unity_TilingAndOffset_float(_Rotate_d6094f9d98974b04867a188c82d5173d_Out_3_Vector2, _Property_4639ccef04594ba9b2025d4663d48618_Out_0_Vector2, _Property_27fd194ce25a4db7b604312a24387d7c_Out_0_Vector2, _TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2);
                                                                                float4 _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.tex, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.samplerstate, _Property_17679afe6f1e4475854469a219dcaf66_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_41a112dc7b134854a8ec1c9fce41ec32_Out_3_Vector2));
                                                                                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_R_4_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.r;
                                                                                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_G_5_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.g;
                                                                                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_B_6_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.b;
                                                                                float _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4.a;
                                                                                float4 _Property_fdab52b7937644c6bd147c5450c3f251_Out_0_Vector4 = _Color;
                                                                                float4 _Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4;
                                                                                Unity_Multiply_float4_float4(_SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_RGBA_0_Vector4, _Property_fdab52b7937644c6bd147c5450c3f251_Out_0_Vector4, _Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4);
                                                                                UnityTexture2D _Property_2a814b19185d49e0b94d6605f815fc22_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Emissions_Mask);
                                                                                float4 _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2a814b19185d49e0b94d6605f815fc22_Out_0_Texture2D.tex, _Property_2a814b19185d49e0b94d6605f815fc22_Out_0_Texture2D.samplerstate, _Property_2a814b19185d49e0b94d6605f815fc22_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                                                                                float _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_R_4_Float = _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4.r;
                                                                                float _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_G_5_Float = _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4.g;
                                                                                float _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_B_6_Float = _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4.b;
                                                                                float _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_A_7_Float = _SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_RGBA_0_Vector4.a;
                                                                                float4 _Multiply_08eeabd84e22476193f424c2d7c85045_Out_2_Vector4;
                                                                                Unity_Multiply_float4_float4(_Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4, (_SampleTexture2D_21a024362f7a4866bd99fd4643f8bdf6_R_4_Float.xxxx), _Multiply_08eeabd84e22476193f424c2d7c85045_Out_2_Vector4);
                                                                                float _Property_f4350f6cd94f4ff688723b2601758647_Out_0_Boolean = _UseNormalMap;
                                                                                UnityTexture2D _Property_2935e6b933c9464c9a226e3939202d3f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
                                                                                float4 _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2935e6b933c9464c9a226e3939202d3f_Out_0_Texture2D.tex, _Property_2935e6b933c9464c9a226e3939202d3f_Out_0_Texture2D.samplerstate, _Property_2935e6b933c9464c9a226e3939202d3f_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                                                                                float _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_R_4_Float = _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4.r;
                                                                                float _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_G_5_Float = _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4.g;
                                                                                float _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_B_6_Float = _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4.b;
                                                                                float _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_A_7_Float = _SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4.a;
                                                                                float4 _Subtract_97b8413d701a46f89b6a6a50965c849b_Out_2_Vector4;
                                                                                Unity_Subtract_float4(_SampleTexture2D_0fcb88e0bf3848b391c444eb16de3156_RGBA_0_Vector4, float4(0.5, 0.5, 0.5, 0.5), _Subtract_97b8413d701a46f89b6a6a50965c849b_Out_2_Vector4);
                                                                                float4 _Multiply_c404d82a7afb45eea38c0f2f8913b3a2_Out_2_Vector4;
                                                                                Unity_Multiply_float4_float4(_Subtract_97b8413d701a46f89b6a6a50965c849b_Out_2_Vector4, float4(2, 2, 2, 2), _Multiply_c404d82a7afb45eea38c0f2f8913b3a2_Out_2_Vector4);
                                                                                float3 _Branch_f5eae9fa1f90448eabeacd6c1897a242_Out_3_Vector3;
                                                                                Unity_Branch_float3(_Property_f4350f6cd94f4ff688723b2601758647_Out_0_Boolean, (_Multiply_c404d82a7afb45eea38c0f2f8913b3a2_Out_2_Vector4.xyz), IN.WorldSpaceNormal, _Branch_f5eae9fa1f90448eabeacd6c1897a242_Out_3_Vector3);
                                                                                float _Property_5c3b0e65e43446d3ae6a44d69cece6ed_Out_0_Float = _Cel_Ramp_Smoothness;
                                                                                float4 _Property_3bfe113ecee2425dbb2ce8c43d76f557_Out_0_Vector4 = _Shading_Color;
                                                                                float _Property_0562fc1a3d1841be83d39c63b4485cee_Out_0_Float = _Cel_Shader_Offset;
                                                                                float Slider_8d27041afd1d4a0c9c60c067176a44c9 = 0.5;
                                                                                float _Property_cbc4f53f5a8e4226b87bb2246a5ed158_Out_0_Float = _Ambient_Self_Lighting;
                                                                                float3 _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_ToonRampOutput_0_Vector3;
                                                                                float3 _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_Direction_7_Vector3;
                                                                                CelShading_float(_Branch_f5eae9fa1f90448eabeacd6c1897a242_Out_3_Vector3, _Property_5c3b0e65e43446d3ae6a44d69cece6ed_Out_0_Float, IN.ObjectSpacePosition, IN.WorldSpacePosition, (_Property_3bfe113ecee2425dbb2ce8c43d76f557_Out_0_Vector4.xyz), _Property_0562fc1a3d1841be83d39c63b4485cee_Out_0_Float, Slider_8d27041afd1d4a0c9c60c067176a44c9, _Property_cbc4f53f5a8e4226b87bb2246a5ed158_Out_0_Float, _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_ToonRampOutput_0_Vector3, _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_Direction_7_Vector3);
                                                                                float _DotProduct_869fe8cb72874c72aabcc111591a62cd_Out_2_Float;
                                                                                Unity_DotProduct_float3(_Branch_f5eae9fa1f90448eabeacd6c1897a242_Out_3_Vector3, _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_Direction_7_Vector3, _DotProduct_869fe8cb72874c72aabcc111591a62cd_Out_2_Float);
                                                                                float _Property_bd8d78e287724bebbeb518d7e1ab0c20_Out_0_Float = _Rim_Lighting;
                                                                                float _FresnelEffect_f452c68b8d004619bb2fa547d94e8942_Out_3_Float;
                                                                                Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_bd8d78e287724bebbeb518d7e1ab0c20_Out_0_Float, _FresnelEffect_f452c68b8d004619bb2fa547d94e8942_Out_3_Float);
                                                                                float _Multiply_500bfd19683e48cbbfd9139fcb7dc218_Out_2_Float;
                                                                                Unity_Multiply_float_float(_DotProduct_869fe8cb72874c72aabcc111591a62cd_Out_2_Float, _FresnelEffect_f452c68b8d004619bb2fa547d94e8942_Out_3_Float, _Multiply_500bfd19683e48cbbfd9139fcb7dc218_Out_2_Float);
                                                                                float _Step_48bb4a882f094cbc9be0e421634c6929_Out_2_Float;
                                                                                Unity_Step_float(float(0.5), _Multiply_500bfd19683e48cbbfd9139fcb7dc218_Out_2_Float, _Step_48bb4a882f094cbc9be0e421634c6929_Out_2_Float);
                                                                                float4 _Multiply_1950ac11d2144717b01dc351ee1c8986_Out_2_Vector4;
                                                                                Unity_Multiply_float4_float4(_Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4, (_Step_48bb4a882f094cbc9be0e421634c6929_Out_2_Float.xxxx), _Multiply_1950ac11d2144717b01dc351ee1c8986_Out_2_Vector4);
                                                                                float _Property_c341dd541b3a425d9d9823d7984f6bf5_Out_0_Float = _Rim_Brightness;
                                                                                float4 _Multiply_91b3bc779fce42e0af22ce8684a3e501_Out_2_Vector4;
                                                                                Unity_Multiply_float4_float4(_Multiply_1950ac11d2144717b01dc351ee1c8986_Out_2_Vector4, (_Property_c341dd541b3a425d9d9823d7984f6bf5_Out_0_Float.xxxx), _Multiply_91b3bc779fce42e0af22ce8684a3e501_Out_2_Vector4);
                                                                                float3 _Multiply_55211470d6b746f5b5fecb73a5dea81b_Out_2_Vector3;
                                                                                Unity_Multiply_float3_float3((_Multiply_91b3bc779fce42e0af22ce8684a3e501_Out_2_Vector4.xyz), _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_ToonRampOutput_0_Vector3, _Multiply_55211470d6b746f5b5fecb73a5dea81b_Out_2_Vector3);
                                                                                float3 _Multiply_6208b7b8f0c543e78a2446e5fc4eb226_Out_2_Vector3;
                                                                                Unity_Multiply_float3_float3((_Multiply_841c0bb066d74e1dba6522734245c435_Out_2_Vector4.xyz), _CelShadingCustomFunction_b2f8d87987bc4015b833784dc6772b6d_ToonRampOutput_0_Vector3, _Multiply_6208b7b8f0c543e78a2446e5fc4eb226_Out_2_Vector3);
                                                                                float3 _Add_6c8423e60dfd4875874ca92d4f743b9e_Out_2_Vector3;
                                                                                Unity_Add_float3(_Multiply_55211470d6b746f5b5fecb73a5dea81b_Out_2_Vector3, _Multiply_6208b7b8f0c543e78a2446e5fc4eb226_Out_2_Vector3, _Add_6c8423e60dfd4875874ca92d4f743b9e_Out_2_Vector3);
                                                                                float3 _Add_e9066678904e4fd590e41227b2822728_Out_2_Vector3;
                                                                                Unity_Add_float3((_Multiply_08eeabd84e22476193f424c2d7c85045_Out_2_Vector4.xyz), _Add_6c8423e60dfd4875874ca92d4f743b9e_Out_2_Vector3, _Add_e9066678904e4fd590e41227b2822728_Out_2_Vector3);
                                                                                float _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float = _Alpha_Clip_Threshold;
                                                                                surface.BaseColor = _Add_e9066678904e4fd590e41227b2822728_Out_2_Vector3;
                                                                                surface.Alpha = _SampleTexture2D_5a632ec083a54beaa4f6d163a195000a_A_7_Float;
                                                                                surface.AlphaClipThreshold = _Property_a5ef6434be044a2585a8dda350103201_Out_0_Float;
                                                                                return surface;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Build Graph Inputs
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                            #endif
                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                            {
                                                                                VertexDescriptionInputs output;
                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                output.ObjectSpacePosition = input.positionOS;

                                                                                return output;
                                                                            }
                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                            {
                                                                                SurfaceDescriptionInputs output;
                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #if VFX_USE_GRAPH_VALUES
                                                                                uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                                                                /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                                                                            #endif
                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                            #endif



                                                                                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                                                float3 unnormalizedNormalWS = input.normalWS;
                                                                                const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                                                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                                                                output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);

                                                                                #if UNITY_UV_STARTS_AT_TOP
                                                                                #else
                                                                                #endif


                                                                                output.uv0 = input.texCoord0;
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                            #else
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                            #endif
                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                    return output;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Main

                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                            // --------------------------------------------------
                                                                            // Visual Effect Vertex Invocations
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                            #endif

                                                                            ENDHLSL
                                                                            }
    }
        CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                                                                CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
                                                                                FallBack "Hidden/Shader Graph/FallbackError"
}
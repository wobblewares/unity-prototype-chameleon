Shader "Wobblewares/Toon Wobble URP"
    {
        Properties
        {
            _Color("Color", Color) = (1, 1, 1, 0)
            _Shadow_Color("Shadow Color", Color) = (0, 0, 0, 0)
            _Diffuse_Map("Diffuse Map", 2D) = "white" {}
            _Wobble_Frequency("Wobble Frequency", Float) = 4
            _Wobble_Frame_Amount("Wobble Frame Amount", Float) = 4
            _Vertex_Wobble("Vertex Wobble", Float) = 0.01
            _Texture_Wobble("Texture Wobble", Float) = 0.01
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
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Opaque"
                "UniversalMaterialType" = "Unlit"
                "Queue"="Geometry"
                "DisableBatching"="False"
                "ShaderGraphShader"="true"
                "ShaderGraphTargetId"="UniversalUnlitSubTarget"
            }
            Pass
            {
                Name "Universal Forward"
                Tags
                {
                    // LightMode: <None>
                }
            
            // Render State
            Cull Back
                Blend One Zero
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
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma shader_feature _ _SAMPLE_GI
                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                #pragma multi_compile_fragment _ DEBUG_DISPLAY
                #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
                #define _FOG_FRAGMENT 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
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
                     float3 ObjectSpacePosition;
                     float3 AbsoluteWorldSpacePosition;
                     float4 uv0;
                     float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 TimeParameters;
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
            
            PackedVaryings PackVaryings (Varyings input)
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
                
                Varyings UnpackVaryings (PackedVaryings input)
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
                float4 _Shadow_Color;
                float4 _Diffuse_Map_TexelSize;
                float4 _Diffuse_Map_ST;
                float _Wobble_Frequency;
                float _Wobble_Frame_Amount;
                float _Vertex_Wobble;
                float _Texture_Wobble;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Diffuse_Map);
                SAMPLER(sampler_Diffuse_Map);
            
            // Graph Includes
            #include "Packages/com.wobblewares.kit/Core/WobbleShader/URP/Shader/CustomLighting.hlsl"
            
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
            
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Modulo_float(float A, float B, out float Out)
                {
                    Out = fmod(A, B);
                }
                
                void Unity_Truncate_float(float In, out float Out)
                {
                    Out = trunc(In);
                }
                
                void Unity_Cosine_float(float In, out float Out)
                {
                    Out = cos(In);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Sine_float3(float3 In, out float3 Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Sine_float2(float2 In, out float2 Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A + B;
                }
                
                void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A * B;
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
                    float _Property_c60f8a7790d244d58b4d40d932657394_Out_0_Float = _Vertex_Wobble;
                    float3 _Swizzle_ecae76e0cc05434e815f24591edc64e2_Out_1_Vector3 = IN.ObjectSpacePosition.yxz;
                    float _Property_29ac532535bf462eb9c9f255c3afb584_Out_0_Float = _Wobble_Frequency;
                    float _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float;
                    Unity_Add_float(IN.TimeParameters.x, 1, _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float);
                    float _Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float;
                    Unity_Multiply_float_float(_Property_29ac532535bf462eb9c9f255c3afb584_Out_0_Float, _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float, _Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float);
                    float _Property_a0404425645e4e7c98fd2f865d50a489_Out_0_Float = _Wobble_Frame_Amount;
                    float _Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float;
                    Unity_Modulo_float(_Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float, _Property_a0404425645e4e7c98fd2f865d50a489_Out_0_Float, _Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float);
                    float _Add_89b1a167679445d798cae7ed037d6141_Out_2_Float;
                    Unity_Add_float(_Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float, 1, _Add_89b1a167679445d798cae7ed037d6141_Out_2_Float);
                    float _Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float;
                    Unity_Truncate_float(_Add_89b1a167679445d798cae7ed037d6141_Out_2_Float, _Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float);
                    float _Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float;
                    Unity_Cosine_float(_Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float, _Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float);
                    float3 _Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3;
                    Unity_Multiply_float3_float3(_Swizzle_ecae76e0cc05434e815f24591edc64e2_Out_1_Vector3, (_Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float.xxx), _Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3);
                    float3 _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3;
                    Unity_Sine_float3(_Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3, _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3);
                    float3 _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3;
                    Unity_Multiply_float3_float3((_Property_c60f8a7790d244d58b4d40d932657394_Out_0_Float.xxx), _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3, _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3);
                    float3 _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3, _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3);
                    description.Position = _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3;
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
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    UnityTexture2D _Property_0a27bb3138a543b1bc294b44dde31c92_Out_0_Texture2D = UnityBuildTexture2DStruct(_Diffuse_Map);
                    float4 _UV_9b7fdf8df83845a9967b16e0ac0a8f2d_Out_0_Vector4 = IN.uv0;
                    float _Property_03ad2699e0da4b42b217d56d30fd90ea_Out_0_Float = _Texture_Wobble;
                    float _Property_29ac532535bf462eb9c9f255c3afb584_Out_0_Float = _Wobble_Frequency;
                    float _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float;
                    Unity_Add_float(IN.TimeParameters.x, 1, _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float);
                    float _Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float;
                    Unity_Multiply_float_float(_Property_29ac532535bf462eb9c9f255c3afb584_Out_0_Float, _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float, _Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float);
                    float _Property_a0404425645e4e7c98fd2f865d50a489_Out_0_Float = _Wobble_Frame_Amount;
                    float _Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float;
                    Unity_Modulo_float(_Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float, _Property_a0404425645e4e7c98fd2f865d50a489_Out_0_Float, _Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float);
                    float _Add_89b1a167679445d798cae7ed037d6141_Out_2_Float;
                    Unity_Add_float(_Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float, 1, _Add_89b1a167679445d798cae7ed037d6141_Out_2_Float);
                    float _Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float;
                    Unity_Truncate_float(_Add_89b1a167679445d798cae7ed037d6141_Out_2_Float, _Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float);
                    float _Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float;
                    Unity_Cosine_float(_Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float, _Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float);
                    float2 _Swizzle_3f9025cb28a244dfbe73a8dc7797a862_Out_1_Vector2 = IN.ObjectSpacePosition.xy;
                    float2 _Multiply_186aca7d6d9d4aafa506ec76347d5e63_Out_2_Vector2;
                    Unity_Multiply_float2_float2((_Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float.xx), _Swizzle_3f9025cb28a244dfbe73a8dc7797a862_Out_1_Vector2, _Multiply_186aca7d6d9d4aafa506ec76347d5e63_Out_2_Vector2);
                    float2 _Sine_44884787c9cb41c7b279e24862fd1faa_Out_1_Vector2;
                    Unity_Sine_float2(_Multiply_186aca7d6d9d4aafa506ec76347d5e63_Out_2_Vector2, _Sine_44884787c9cb41c7b279e24862fd1faa_Out_1_Vector2);
                    float2 _Multiply_a536152159744e33b662cd4c56d2bc39_Out_2_Vector2;
                    Unity_Multiply_float2_float2((_Property_03ad2699e0da4b42b217d56d30fd90ea_Out_0_Float.xx), _Sine_44884787c9cb41c7b279e24862fd1faa_Out_1_Vector2, _Multiply_a536152159744e33b662cd4c56d2bc39_Out_2_Vector2);
                    float2 _Add_34c913d283004e88920da5a11186bb5c_Out_2_Vector2;
                    Unity_Add_float2((_UV_9b7fdf8df83845a9967b16e0ac0a8f2d_Out_0_Vector4.xy), _Multiply_a536152159744e33b662cd4c56d2bc39_Out_2_Vector2, _Add_34c913d283004e88920da5a11186bb5c_Out_2_Vector2);
                    float4 _SampleTexture2D_5c6b2cbf0606407883a2ab4fb7ac3889_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_0a27bb3138a543b1bc294b44dde31c92_Out_0_Texture2D.tex, _Property_0a27bb3138a543b1bc294b44dde31c92_Out_0_Texture2D.samplerstate, _Property_0a27bb3138a543b1bc294b44dde31c92_Out_0_Texture2D.GetTransformedUV(_Add_34c913d283004e88920da5a11186bb5c_Out_2_Vector2) );
                    float _SampleTexture2D_5c6b2cbf0606407883a2ab4fb7ac3889_R_4_Float = _SampleTexture2D_5c6b2cbf0606407883a2ab4fb7ac3889_RGBA_0_Vector4.r;
                    float _SampleTexture2D_5c6b2cbf0606407883a2ab4fb7ac3889_G_5_Float = _SampleTexture2D_5c6b2cbf0606407883a2ab4fb7ac3889_RGBA_0_Vector4.g;
                    float _SampleTexture2D_5c6b2cbf0606407883a2ab4fb7ac3889_B_6_Float = _SampleTexture2D_5c6b2cbf0606407883a2ab4fb7ac3889_RGBA_0_Vector4.b;
                    float _SampleTexture2D_5c6b2cbf0606407883a2ab4fb7ac3889_A_7_Float = _SampleTexture2D_5c6b2cbf0606407883a2ab4fb7ac3889_RGBA_0_Vector4.a;
                    float4 _Property_8ec4f8e6df4b43778529405fca5acc88_Out_0_Vector4 = _Shadow_Color;
                    float4 _Property_fe1180c44c3e485ab10916c405a7625f_Out_0_Vector4 = _Color;
                    float3 _MainLightCustomFunction_914b3a1611644197933da92eb48c0288_Direction_0_Vector3;
                    float _MainLightCustomFunction_914b3a1611644197933da92eb48c0288_ShadowAtten_3_Float;
                    MainLight_float(IN.AbsoluteWorldSpacePosition, _MainLightCustomFunction_914b3a1611644197933da92eb48c0288_Direction_0_Vector3, _MainLightCustomFunction_914b3a1611644197933da92eb48c0288_ShadowAtten_3_Float);
                    float _DotProduct_c3b16700b6cd427891521efb0893a054_Out_2_Float;
                    Unity_DotProduct_float3(_MainLightCustomFunction_914b3a1611644197933da92eb48c0288_Direction_0_Vector3, IN.WorldSpaceNormal, _DotProduct_c3b16700b6cd427891521efb0893a054_Out_2_Float);
                    float _Multiply_425542ae786c44a4a8e4241e8210f6f1_Out_2_Float;
                    Unity_Multiply_float_float(_MainLightCustomFunction_914b3a1611644197933da92eb48c0288_ShadowAtten_3_Float, _DotProduct_c3b16700b6cd427891521efb0893a054_Out_2_Float, _Multiply_425542ae786c44a4a8e4241e8210f6f1_Out_2_Float);
                    float _Smoothstep_575ed0e828254fee8ec748a20dbe0e9f_Out_3_Float;
                    Unity_Smoothstep_float(0, 0.01, _Multiply_425542ae786c44a4a8e4241e8210f6f1_Out_2_Float, _Smoothstep_575ed0e828254fee8ec748a20dbe0e9f_Out_3_Float);
                    float4 _Lerp_c16b9f4157b44c8391d35190dc6bcae5_Out_3_Vector4;
                    Unity_Lerp_float4(_Property_8ec4f8e6df4b43778529405fca5acc88_Out_0_Vector4, _Property_fe1180c44c3e485ab10916c405a7625f_Out_0_Vector4, (_Smoothstep_575ed0e828254fee8ec748a20dbe0e9f_Out_3_Float.xxxx), _Lerp_c16b9f4157b44c8391d35190dc6bcae5_Out_3_Vector4);
                    float4 _Multiply_83384913df32447f8ba5c318ab0216fa_Out_2_Vector4;
                    Unity_Multiply_float4_float4(_SampleTexture2D_5c6b2cbf0606407883a2ab4fb7ac3889_RGBA_0_Vector4, _Lerp_c16b9f4157b44c8391d35190dc6bcae5_Out_3_Vector4, _Multiply_83384913df32447f8ba5c318ab0216fa_Out_2_Vector4);
                    surface.BaseColor = (_Multiply_83384913df32447f8ba5c318ab0216fa_Out_2_Vector4.xyz);
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
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.TimeParameters =                             _TimeParameters.xyz;
                
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
                
                
                    output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
                    output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
                
                    #if UNITY_UV_STARTS_AT_TOP
                    #else
                    #endif
                
                
                    output.uv0 = input.texCoord0;
                    output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
            
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
            Cull Back
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
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
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
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
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
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
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
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
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
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
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
                float4 _Shadow_Color;
                float4 _Diffuse_Map_TexelSize;
                float4 _Diffuse_Map_ST;
                float _Wobble_Frequency;
                float _Wobble_Frame_Amount;
                float _Vertex_Wobble;
                float _Texture_Wobble;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Diffuse_Map);
                SAMPLER(sampler_Diffuse_Map);
            
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
            
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Modulo_float(float A, float B, out float Out)
                {
                    Out = fmod(A, B);
                }
                
                void Unity_Truncate_float(float In, out float Out)
                {
                    Out = trunc(In);
                }
                
                void Unity_Cosine_float(float In, out float Out)
                {
                    Out = cos(In);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Sine_float3(float3 In, out float3 Out)
                {
                    Out = sin(In);
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
                    float _Property_c60f8a7790d244d58b4d40d932657394_Out_0_Float = _Vertex_Wobble;
                    float3 _Swizzle_ecae76e0cc05434e815f24591edc64e2_Out_1_Vector3 = IN.ObjectSpacePosition.yxz;
                    float _Property_29ac532535bf462eb9c9f255c3afb584_Out_0_Float = _Wobble_Frequency;
                    float _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float;
                    Unity_Add_float(IN.TimeParameters.x, 1, _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float);
                    float _Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float;
                    Unity_Multiply_float_float(_Property_29ac532535bf462eb9c9f255c3afb584_Out_0_Float, _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float, _Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float);
                    float _Property_a0404425645e4e7c98fd2f865d50a489_Out_0_Float = _Wobble_Frame_Amount;
                    float _Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float;
                    Unity_Modulo_float(_Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float, _Property_a0404425645e4e7c98fd2f865d50a489_Out_0_Float, _Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float);
                    float _Add_89b1a167679445d798cae7ed037d6141_Out_2_Float;
                    Unity_Add_float(_Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float, 1, _Add_89b1a167679445d798cae7ed037d6141_Out_2_Float);
                    float _Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float;
                    Unity_Truncate_float(_Add_89b1a167679445d798cae7ed037d6141_Out_2_Float, _Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float);
                    float _Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float;
                    Unity_Cosine_float(_Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float, _Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float);
                    float3 _Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3;
                    Unity_Multiply_float3_float3(_Swizzle_ecae76e0cc05434e815f24591edc64e2_Out_1_Vector3, (_Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float.xxx), _Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3);
                    float3 _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3;
                    Unity_Sine_float3(_Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3, _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3);
                    float3 _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3;
                    Unity_Multiply_float3_float3((_Property_c60f8a7790d244d58b4d40d932657394_Out_0_Float.xxx), _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3, _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3);
                    float3 _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3, _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3);
                    description.Position = _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3;
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
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
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
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.TimeParameters =                             _TimeParameters.xyz;
                
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
                Name "DepthNormalsOnly"
                Tags
                {
                    "LightMode" = "DepthNormalsOnly"
                }
            
            // Render State
            Cull Back
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
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_NORMAL_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
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
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 normalWS;
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
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 normalWS : INTERP0;
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
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
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
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
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
                float4 _Shadow_Color;
                float4 _Diffuse_Map_TexelSize;
                float4 _Diffuse_Map_ST;
                float _Wobble_Frequency;
                float _Wobble_Frame_Amount;
                float _Vertex_Wobble;
                float _Texture_Wobble;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Diffuse_Map);
                SAMPLER(sampler_Diffuse_Map);
            
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
            
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Modulo_float(float A, float B, out float Out)
                {
                    Out = fmod(A, B);
                }
                
                void Unity_Truncate_float(float In, out float Out)
                {
                    Out = trunc(In);
                }
                
                void Unity_Cosine_float(float In, out float Out)
                {
                    Out = cos(In);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Sine_float3(float3 In, out float3 Out)
                {
                    Out = sin(In);
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
                    float _Property_c60f8a7790d244d58b4d40d932657394_Out_0_Float = _Vertex_Wobble;
                    float3 _Swizzle_ecae76e0cc05434e815f24591edc64e2_Out_1_Vector3 = IN.ObjectSpacePosition.yxz;
                    float _Property_29ac532535bf462eb9c9f255c3afb584_Out_0_Float = _Wobble_Frequency;
                    float _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float;
                    Unity_Add_float(IN.TimeParameters.x, 1, _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float);
                    float _Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float;
                    Unity_Multiply_float_float(_Property_29ac532535bf462eb9c9f255c3afb584_Out_0_Float, _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float, _Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float);
                    float _Property_a0404425645e4e7c98fd2f865d50a489_Out_0_Float = _Wobble_Frame_Amount;
                    float _Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float;
                    Unity_Modulo_float(_Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float, _Property_a0404425645e4e7c98fd2f865d50a489_Out_0_Float, _Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float);
                    float _Add_89b1a167679445d798cae7ed037d6141_Out_2_Float;
                    Unity_Add_float(_Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float, 1, _Add_89b1a167679445d798cae7ed037d6141_Out_2_Float);
                    float _Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float;
                    Unity_Truncate_float(_Add_89b1a167679445d798cae7ed037d6141_Out_2_Float, _Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float);
                    float _Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float;
                    Unity_Cosine_float(_Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float, _Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float);
                    float3 _Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3;
                    Unity_Multiply_float3_float3(_Swizzle_ecae76e0cc05434e815f24591edc64e2_Out_1_Vector3, (_Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float.xxx), _Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3);
                    float3 _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3;
                    Unity_Sine_float3(_Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3, _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3);
                    float3 _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3;
                    Unity_Multiply_float3_float3((_Property_c60f8a7790d244d58b4d40d932657394_Out_0_Float.xxx), _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3, _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3);
                    float3 _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3, _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3);
                    description.Position = _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3;
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
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
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
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.TimeParameters =                             _TimeParameters.xyz;
                
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
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
            
            // Render State
            Cull Back
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
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_NORMAL_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
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
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 normalWS;
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
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 normalWS : INTERP0;
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
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
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
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
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
                float4 _Shadow_Color;
                float4 _Diffuse_Map_TexelSize;
                float4 _Diffuse_Map_ST;
                float _Wobble_Frequency;
                float _Wobble_Frame_Amount;
                float _Vertex_Wobble;
                float _Texture_Wobble;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Diffuse_Map);
                SAMPLER(sampler_Diffuse_Map);
            
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
            
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Modulo_float(float A, float B, out float Out)
                {
                    Out = fmod(A, B);
                }
                
                void Unity_Truncate_float(float In, out float Out)
                {
                    Out = trunc(In);
                }
                
                void Unity_Cosine_float(float In, out float Out)
                {
                    Out = cos(In);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Sine_float3(float3 In, out float3 Out)
                {
                    Out = sin(In);
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
                    float _Property_c60f8a7790d244d58b4d40d932657394_Out_0_Float = _Vertex_Wobble;
                    float3 _Swizzle_ecae76e0cc05434e815f24591edc64e2_Out_1_Vector3 = IN.ObjectSpacePosition.yxz;
                    float _Property_29ac532535bf462eb9c9f255c3afb584_Out_0_Float = _Wobble_Frequency;
                    float _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float;
                    Unity_Add_float(IN.TimeParameters.x, 1, _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float);
                    float _Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float;
                    Unity_Multiply_float_float(_Property_29ac532535bf462eb9c9f255c3afb584_Out_0_Float, _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float, _Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float);
                    float _Property_a0404425645e4e7c98fd2f865d50a489_Out_0_Float = _Wobble_Frame_Amount;
                    float _Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float;
                    Unity_Modulo_float(_Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float, _Property_a0404425645e4e7c98fd2f865d50a489_Out_0_Float, _Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float);
                    float _Add_89b1a167679445d798cae7ed037d6141_Out_2_Float;
                    Unity_Add_float(_Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float, 1, _Add_89b1a167679445d798cae7ed037d6141_Out_2_Float);
                    float _Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float;
                    Unity_Truncate_float(_Add_89b1a167679445d798cae7ed037d6141_Out_2_Float, _Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float);
                    float _Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float;
                    Unity_Cosine_float(_Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float, _Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float);
                    float3 _Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3;
                    Unity_Multiply_float3_float3(_Swizzle_ecae76e0cc05434e815f24591edc64e2_Out_1_Vector3, (_Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float.xxx), _Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3);
                    float3 _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3;
                    Unity_Sine_float3(_Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3, _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3);
                    float3 _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3;
                    Unity_Multiply_float3_float3((_Property_c60f8a7790d244d58b4d40d932657394_Out_0_Float.xxx), _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3, _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3);
                    float3 _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3, _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3);
                    description.Position = _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3;
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
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
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
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.TimeParameters =                             _TimeParameters.xyz;
                
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
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
                #define SCENESELECTIONPASS 1
                #define ALPHA_CLIP_THRESHOLD 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
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
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
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
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
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
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
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
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
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
                float4 _Shadow_Color;
                float4 _Diffuse_Map_TexelSize;
                float4 _Diffuse_Map_ST;
                float _Wobble_Frequency;
                float _Wobble_Frame_Amount;
                float _Vertex_Wobble;
                float _Texture_Wobble;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Diffuse_Map);
                SAMPLER(sampler_Diffuse_Map);
            
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
            
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Modulo_float(float A, float B, out float Out)
                {
                    Out = fmod(A, B);
                }
                
                void Unity_Truncate_float(float In, out float Out)
                {
                    Out = trunc(In);
                }
                
                void Unity_Cosine_float(float In, out float Out)
                {
                    Out = cos(In);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Sine_float3(float3 In, out float3 Out)
                {
                    Out = sin(In);
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
                    float _Property_c60f8a7790d244d58b4d40d932657394_Out_0_Float = _Vertex_Wobble;
                    float3 _Swizzle_ecae76e0cc05434e815f24591edc64e2_Out_1_Vector3 = IN.ObjectSpacePosition.yxz;
                    float _Property_29ac532535bf462eb9c9f255c3afb584_Out_0_Float = _Wobble_Frequency;
                    float _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float;
                    Unity_Add_float(IN.TimeParameters.x, 1, _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float);
                    float _Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float;
                    Unity_Multiply_float_float(_Property_29ac532535bf462eb9c9f255c3afb584_Out_0_Float, _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float, _Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float);
                    float _Property_a0404425645e4e7c98fd2f865d50a489_Out_0_Float = _Wobble_Frame_Amount;
                    float _Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float;
                    Unity_Modulo_float(_Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float, _Property_a0404425645e4e7c98fd2f865d50a489_Out_0_Float, _Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float);
                    float _Add_89b1a167679445d798cae7ed037d6141_Out_2_Float;
                    Unity_Add_float(_Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float, 1, _Add_89b1a167679445d798cae7ed037d6141_Out_2_Float);
                    float _Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float;
                    Unity_Truncate_float(_Add_89b1a167679445d798cae7ed037d6141_Out_2_Float, _Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float);
                    float _Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float;
                    Unity_Cosine_float(_Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float, _Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float);
                    float3 _Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3;
                    Unity_Multiply_float3_float3(_Swizzle_ecae76e0cc05434e815f24591edc64e2_Out_1_Vector3, (_Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float.xxx), _Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3);
                    float3 _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3;
                    Unity_Sine_float3(_Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3, _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3);
                    float3 _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3;
                    Unity_Multiply_float3_float3((_Property_c60f8a7790d244d58b4d40d932657394_Out_0_Float.xxx), _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3, _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3);
                    float3 _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3, _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3);
                    description.Position = _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3;
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
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
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
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.TimeParameters =                             _TimeParameters.xyz;
                
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
            Cull Back
            
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
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
                #define SCENEPICKINGPASS 1
                #define ALPHA_CLIP_THRESHOLD 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
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
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
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
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
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
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
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
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
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
                float4 _Shadow_Color;
                float4 _Diffuse_Map_TexelSize;
                float4 _Diffuse_Map_ST;
                float _Wobble_Frequency;
                float _Wobble_Frame_Amount;
                float _Vertex_Wobble;
                float _Texture_Wobble;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Diffuse_Map);
                SAMPLER(sampler_Diffuse_Map);
            
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
            
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Modulo_float(float A, float B, out float Out)
                {
                    Out = fmod(A, B);
                }
                
                void Unity_Truncate_float(float In, out float Out)
                {
                    Out = trunc(In);
                }
                
                void Unity_Cosine_float(float In, out float Out)
                {
                    Out = cos(In);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Sine_float3(float3 In, out float3 Out)
                {
                    Out = sin(In);
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
                    float _Property_c60f8a7790d244d58b4d40d932657394_Out_0_Float = _Vertex_Wobble;
                    float3 _Swizzle_ecae76e0cc05434e815f24591edc64e2_Out_1_Vector3 = IN.ObjectSpacePosition.yxz;
                    float _Property_29ac532535bf462eb9c9f255c3afb584_Out_0_Float = _Wobble_Frequency;
                    float _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float;
                    Unity_Add_float(IN.TimeParameters.x, 1, _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float);
                    float _Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float;
                    Unity_Multiply_float_float(_Property_29ac532535bf462eb9c9f255c3afb584_Out_0_Float, _Add_f07b762122bb45868c758110b3abbecc_Out_2_Float, _Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float);
                    float _Property_a0404425645e4e7c98fd2f865d50a489_Out_0_Float = _Wobble_Frame_Amount;
                    float _Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float;
                    Unity_Modulo_float(_Multiply_7696fbd9412640b8a9e39564d54d66b1_Out_2_Float, _Property_a0404425645e4e7c98fd2f865d50a489_Out_0_Float, _Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float);
                    float _Add_89b1a167679445d798cae7ed037d6141_Out_2_Float;
                    Unity_Add_float(_Modulo_e31f8523c50249088e0183d0e9145441_Out_2_Float, 1, _Add_89b1a167679445d798cae7ed037d6141_Out_2_Float);
                    float _Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float;
                    Unity_Truncate_float(_Add_89b1a167679445d798cae7ed037d6141_Out_2_Float, _Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float);
                    float _Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float;
                    Unity_Cosine_float(_Truncate_6fcd98b1d2844b8db91f2d8ac87cd125_Out_1_Float, _Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float);
                    float3 _Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3;
                    Unity_Multiply_float3_float3(_Swizzle_ecae76e0cc05434e815f24591edc64e2_Out_1_Vector3, (_Cosine_db400684f5754ec480e4bb1c5d7b25e7_Out_1_Float.xxx), _Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3);
                    float3 _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3;
                    Unity_Sine_float3(_Multiply_b61f94100eaa4b29a612a887b17b266d_Out_2_Vector3, _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3);
                    float3 _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3;
                    Unity_Multiply_float3_float3((_Property_c60f8a7790d244d58b4d40d932657394_Out_0_Float.xxx), _Sine_123a56a8804045a58e24c980bb243c56_Out_1_Vector3, _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3);
                    float3 _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_6eff9633abfb4d9b90d4008dcc843547_Out_2_Vector3, _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3);
                    description.Position = _Add_2b3b3ac12bc640d2a5058ab434216f20_Out_2_Vector3;
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
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
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
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                    output.TimeParameters =                             _TimeParameters.xyz;
                
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
        }
        CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
        CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
        FallBack "Hidden/Shader Graph/FallbackError"
    }
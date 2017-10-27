// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PolyPixel/Standard Shader"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_MaskClipValue( "Mask Clip Value", Float ) = 0.5
		_TextureUV("Texture UV", Float) = 1
		_AlbedoColor("Albedo Color", Color) = (1,1,1,0)
		_AlbedoMap("Albedo Map", 2D) = "white" {}
		[Toggle]_UseAlphaCutoff("Use Alpha Cutoff", Float) = 0
		_AlphaCutoff("Alpha Cutoff", Range( 0 , 1)) = 0.4
		[Toggle]_UseEmmisive("Use Emmisive", Float) = 0
		_EmissiveColor("Emissive Color", Color) = (1,1,1,0)
		_EmissiveStrength("Emissive Strength", Float) = 0
		_NormalMap("Normal Map", 2D) = "white" {}
		_NormalScale("Normal Scale", Float) = 0
		_CompactMap("Compact Map", 2D) = "white" {}
		_Metalic("Metalic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_AmbientOcclusion("Ambient Occlusion", Range( 0 , 1)) = 0
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 texcoord_0;
		};

		uniform float _NormalScale;
		uniform sampler2D _NormalMap;
		uniform float _TextureUV;
		uniform float4 _AlbedoColor;
		uniform sampler2D _AlbedoMap;
		uniform float _UseEmmisive;
		uniform float4 _EmissiveColor;
		uniform float _EmissiveStrength;
		uniform sampler2D _CompactMap;
		uniform float _Metalic;
		uniform float _Smoothness;
		uniform float _AmbientOcclusion;
		uniform float _UseAlphaCutoff;
		uniform float _AlphaCutoff;
		uniform float _MaskClipValue = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.texcoord_0.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_output_31_0 = ( i.texcoord_0 * _TextureUV );
			o.Normal = UnpackScaleNormal( tex2D( _NormalMap, temp_output_31_0 ) ,_NormalScale );
			float4 tex2DNode1 = tex2D( _AlbedoMap, temp_output_31_0 );
			o.Albedo = ( _AlbedoColor * tex2DNode1 ).rgb;
			o.Emission = lerp(tex2DNode1,( _EmissiveColor * _EmissiveStrength ),_UseEmmisive).rgb;
			float4 tex2DNode3 = tex2D( _CompactMap, temp_output_31_0 );
			o.Metallic = ( tex2DNode3.r * _Metalic );
			o.Smoothness = ( tex2DNode3.g * _Smoothness );
			o.Occlusion = ( tex2DNode3.b * _AmbientOcclusion );
			o.Alpha = lerp(1.0,( ( tex2DNode1.a + _AlphaCutoff ) * _AlphaCutoff ),_UseAlphaCutoff);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			# include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD6;
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
//				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
//				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
//				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
//				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				fixed3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
//				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
//				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
//				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
//				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			fixed4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
//				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13101
290;40;1266;659;2556.155;301.4241;2.829892;True;True
Node;AmplifyShaderEditor.CommentaryNode;32;-1451.407,-337.0222;Float;False;438;393;Texture UV;3;31;30;29;Texture UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-1427.407,-259.0223;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;30;-1401.407,-85.0223;Float;False;Property;_TextureUV;Texture UV;1;0;1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;35;-444.7242,-342.1795;Float;False;629.8651;397.2322;Alpha Cutoff;5;37;38;36;34;39;Alpha Cutoff;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1171.407,-184.0224;Float;False;2;2;0;FLOAT2;0.0;False;1;FLOAT;0.0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.CommentaryNode;8;-950.4689,-357.9945;Float;False;458.8;441.9;Albedo;3;6;1;7;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-418.2704,-121.4047;Float;False;Property;_AlphaCutoff;Alpha Cutoff;5;0;0.4;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;1;-937.4692,-112.2946;Float;True;Property;_AlbedoMap;Albedo Map;3;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;19;-949.1456,-751.6157;Float;False;763.8818;339.5712;Emission;4;16;15;13;14;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;33;-961.9293,449.207;Float;False;782.2;575.1;Compact Map;7;21;24;23;27;26;25;3;Compact Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;20;-1162.796,115.3581;Float;False;624;268;Normal Map;2;40;2;Normal Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-914.0623,-503.7129;Float;False;Property;_EmissiveStrength;Emissive Strength;8;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;13;-917.0331,-694.8888;Float;False;Property;_EmissiveColor;Emissive Color;7;0;1,1,1,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-269.0114,-237.9552;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;6;-937.4687,-298.1945;Float;False;Property;_AlbedoColor;Albedo Color;2;0;1,1,1,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;21;-878.3138,711.8523;Float;False;Property;_Metalic;Metalic;12;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;40;-1149.574,223.6253;Float;False;Property;_NormalScale;Normal Scale;10;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;24;-876.2137,827.7524;Float;False;Property;_Smoothness;Smoothness;13;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;23;-869.4136,922.6522;Float;False;Property;_AmbientOcclusion;Ambient Occlusion;14;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-109.3454,-228.9273;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;39;-415.9436,-30.03746;Float;False;Constant;_AlphaOff;Alpha Off;14;0;1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;3;-881.5105,498.9236;Float;True;Property;_CompactMap;Compact Map;11;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-623.1945,-628.4321;Float;False;2;2;0;COLOR;0.0;False;1;FLOAT;0.0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ToggleSwitchNode;16;-424.4781,-568.4868;Float;False;Property;_UseEmmisive;Use Emmisive;6;1;[Toggle];0;2;0;COLOR;0.0;False;1;COLOR;0.0;False;1;COLOR
Node;AmplifyShaderEditor.ToggleSwitchNode;34;-69.31297,-74.96224;Float;False;Property;_UseAlphaCutoff;Use Alpha Cutoff;4;1;[Toggle];0;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-647.5694,-239.6947;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0.0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-523.1139,766.6522;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;2;-885.448,180.9571;Float;True;Property;_NormalMap;Normal Map;9;0;None;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-517.4139,644.2522;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-527.0137,890.6524;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;339.6837,-346.5078;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;PolyPixel/Standard Shader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;Custom;0.5;True;True;0;True;Transparent;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;31;0;29;0
WireConnection;31;1;30;0
WireConnection;1;1;31;0
WireConnection;38;0;1;4
WireConnection;38;1;36;0
WireConnection;37;0;38;0
WireConnection;37;1;36;0
WireConnection;3;1;31;0
WireConnection;15;0;13;0
WireConnection;15;1;14;0
WireConnection;16;0;1;0
WireConnection;16;1;15;0
WireConnection;34;0;39;0
WireConnection;34;1;37;0
WireConnection;7;0;6;0
WireConnection;7;1;1;0
WireConnection;26;0;3;2
WireConnection;26;1;24;0
WireConnection;2;1;31;0
WireConnection;2;5;40;0
WireConnection;25;0;3;1
WireConnection;25;1;21;0
WireConnection;27;0;3;3
WireConnection;27;1;23;0
WireConnection;0;0;7;0
WireConnection;0;1;2;0
WireConnection;0;2;16;0
WireConnection;0;3;25;0
WireConnection;0;4;26;0
WireConnection;0;5;27;0
WireConnection;0;9;34;0
ASEEND*/
//CHKSM=33934AF8598D736F8F4A537438680D8358B788DD
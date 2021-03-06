// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "17Innerline"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		
		_InnerOutlineColor("InnerOutlineColor" , Color  ) = (1,1,1,1)
        _Width("OutlineWidth" , Range(0,2)) = 1
        _Alpha("Alpha" , Float) = 1
        _Glow("Glow" , Float) = 1
	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		
		
		Pass
		{
		CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc"
			

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform float _EnableExternalAlpha;
			uniform sampler2D _MainTex;
			uniform sampler2D _AlphaTex;
			float4 _InnerlineColor;
            float _Width;
            float _Glow;
            float _Alpha;
			
			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				
				
				IN.vertex.xyz +=  float3(0,0,0) ; 
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			fixed4 SampleSpriteTexture (float2 uv)
			{
				fixed4 color = tex2D (_MainTex, uv);

#if ETC1_EXTERNAL_ALPHA
				// get the color from an external texture (usecase: Alpha support for ETC1 on android)
				fixed4 alpha = tex2D (_AlphaTex, uv);
				color.a = lerp (color.a, alpha.r, _EnableExternalAlpha);
#endif //ETC1_EXTERNAL_ALPHA

				return color;
			}

			// inline fixed3 _GetPixel(float offsetX, float offsetY, fixed2 uv, sampler2D tex){
			// 	return tex2D(tex, (uv + fixed2(offsetX ,offsetY))).rgb;
			// }

			// // ????????????
			// float4 DrawInnerOutline(float4 rawCol,sampler2D tex,float2 uv,float4 outlineColor,float width,float alpha,float glow){
			// 	fixed3 col = abs(_GetPixel(0, width, uv, tex) - _GetPixel(0, -width, uv, tex));
			// 	col += abs(_GetPixel(width, 0, uv, tex) - _GetPixel(-width, 0, uv, tex));
			// 	col *= rawCol.a * alpha;
			// 	float outlineVal =  length(col) * glow;
			// 	rawCol.rgb = lerp(rawCol.rgb,outlineColor.rgb,outlineVal);
			// 	return rawCol;
			// }

			inline fixed3 _GetPixel(sampler2D tex,float2 uv, float offset_x,float offset_y){
                return tex2D(tex, ( uv + float2(offset_x,offset_y))) .rgb;
            }

            float4 DrawInnerOutline(sampler2D tex,float4 rawCol, float2 uv,float4 outlineColor,float alpha,float width,float glow){
                float3 col =abs(_GetPixel(tex,uv , 0,width ) - _GetPixel(tex,uv , 0,-width ));
                col += abs(_GetPixel(tex,uv , width,0 ) - _GetPixel(tex,uv , -width,0 )); 

                col *= rawCol.a * alpha;
                fixed4 innerOutlineVal = length(col) * glow;
                rawCol.rgb = lerp(rawCol.rgb,outlineColor,innerOutlineVal);
                return rawCol;
            }
			
			fixed4 frag(v2f IN  ) : SV_Target
			{
				
				fixed4 c = SampleSpriteTexture (IN.texcoord) * IN.color;
				c.rgb *= c.a;
				// c = DrawInnerOutline(c,_MainTex,IN.texcoord,_InnerlineColor,_Width,_Alpha,_Glow);
				c = DrawInnerOutline(_MainTex,c,IN.texcoord,_InnerlineColor,_Alpha,_Width,_Glow);
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17500
0;21;1303;1383;651.5;691.5;1;True;True
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;1;17Innerline;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;False;-1;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;0
ASEEND*/
//CHKSM=C50545885418114802331DF946A2E6C144BC3949
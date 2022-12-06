Shader "Unlit/cut3_CylinderScreenShader"
{
    Properties
    {
        _ScreenHeight("Screen Height", Range(0.0001,5)) = 1
        _MainTex ("Texture", 2D) = "white" {}
        _EndOfScreenAngle("ScreenAngle", Range(0.1, 180)) = 90
        _SplitAngle("SplitAngle", Range(0.1,180)) = 30
        //_SplitScreen("SplitScreen", Int) = 3
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal :NORMAL;
                float2 uv : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 WorldNormal : TEXCOORD1;
                float3 PosWS : TEXCOORD2;
                float4 PosLS : TEXCOORD3;
                float4 PosCS : SV_POSITION;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _ScreenHeight;
            float _EndOfScreenAngle;
            float _SplitAngle;
            int _SplitScreen;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.PosLS = v.vertex;
                
                float3 LS = normalize(float3(o.PosLS.r,o.PosLS.g,0));
                
                float rad = _EndOfScreenAngle * UNITY_PI / 180.0;
                float2 EndScreenDir = float2(cos(rad), sin(rad));
                float SplitAngle = _SplitAngle * UNITY_PI / 180.0;

                
                float2 StartScreenDir = float2(1, 0);
                float2 StartScreenDirLeft = float2(0, -1);
                float2 StartScreenDirRight = float2(0, 1);
                //从屏幕中心到两边的角度
                float TotalAngle = 2 * acos(dot(StartScreenDir, EndScreenDir));
                float theta = 0;
                float z = 0;
                
                if(o.PosLS.g <= -sqrt(2.0)/2.0)
                {//取左边
                    //取theta的百分比
                    float pre = acos(dot(LS, float3(StartScreenDirLeft, 0))) / SplitAngle;
                    if(o.PosLS.r >= 0)
                    {
                        //只有右边会超过1，超出部分删除（在frag阶段，这里置2.0）
                        theta = (0.5 + 0.5 * pre) >= 1.0 ? 2.0 : (0.0 / 3.0 + (0.5 + 0.5 * pre) / 3.0);
                    }
                    else
                    {
                        theta = (0.5 - 0.5 * pre) / 3.0;
                    }
                }
                else if(o.PosLS.g >= sqrt(2.0)/2.0)
                {//取右边
                    float pre = acos(dot(LS, float3(StartScreenDirRight, 0))) / SplitAngle;
                    if(o.PosLS.r >= 0)
                    {
                        //只有左边会小于1，超出部分删除（在frag阶段，这里置2.0）
                        theta = (0.5 - 0.5 * pre) <= 0.0 ? 2.0 : (2.0 / 3.0 + (0.5 - 0.5 * pre) / 3.0);
                    }
                    else
                    {
                        theta = 2.0 / 3.0 + (0.5 + 0.5 * pre) / 3.0;
                    }
                }
                else{
                    //中间
                    float pre = acos(dot(LS, float3(StartScreenDir, 0))) / SplitAngle;
                    //左右超出部分删除
                    if(o.PosLS.g >= 0)
                    {
                        theta =  (0.5 + 0.5 * pre) >= 1.0 ? 2.0 : (1.0 / 3.0 +  (0.5 + 0.5 * pre) / 3.0);
                    }
                    else
                    {
                        theta = (0.5 - 0.5 * pre) <= 0.0 ? 2.0 : (1.0 / 3.0 + (0.5 - 0.5 * pre) / 3.0);
                    }  
                }
                
                z = (o.PosLS.b  + _ScreenHeight/2.f) / _ScreenHeight;

                o.uv = float2(theta, z);
                o.PosCS = UnityObjectToClipPos(v.vertex);
                o.WorldNormal = UnityObjectToWorldNormal(v.normal.xyz);
                o.PosWS = mul(unity_ObjectToWorld, v.vertex);
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = 0;
                if(i.uv.x <= 1.f && i.uv.x >= 0.f && i.uv.y <= 1.f && i.uv.y >= 0.f)
                {
                    col = tex2D(_MainTex, i.uv);
                }
                else
                {
                    col = 0;
                }
                //col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}

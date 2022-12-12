Shader "Unlit/cut3_CylinderScreenShader"
{
    Properties
    {
        _ScreenHeight("Screen Height", Range(0.0001,5)) = 1
        _MainTex ("Texture", 2D) = "white" {}
        _EndOfScreenAngle("ScreenAngle", Range(0.1, 180)) = 90
        _SplitAngle("SplitAngle", Range(0.1,180)) = 30
        _SplitNum("SplitNum", Int) = 3
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
            int _SplitNum;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.PosLS = v.vertex;

                //local position
                float3 LP = normalize(float3(o.PosLS.r,o.PosLS.g,0));

                //每一份屏幕的宽度
                float SplitAngle = _SplitAngle * UNITY_PI / 180.0;

                //屏幕总宽度
                float rad = _EndOfScreenAngle * UNITY_PI / 180.0;
                float2 EndScreenRightDir = float2(cos(rad), sin(rad));
                float2 EndScreenLeftDir = float2(cos(rad), -sin(rad));
                float2 StartScreenDir = float2(1, 0);
                //从屏幕反向中心到两边的角度
                float TotalAngle = 2 * acos(dot(StartScreenDir, EndScreenRightDir));

                //uv采样 theta & z -> [0,1]
                float theta = 0;
                float z = 0;
                //又因为是圆柱，z采样不变
                z = (o.PosLS.b  + _ScreenHeight/2.f) / _ScreenHeight;

                //-------------------theta------------------------------//
                float EachSplitAngle = TotalAngle / float(_SplitNum);
                float2 CenterLineArray[100];

                for(int i = 0; i < _SplitNum; i++)
                {
                    //新中心与左边缘夹角
                    float belta = EachSplitAngle * i + EachSplitAngle / 2.0;
                    CenterLineArray[i] = float2(cos(rad - belta), -1 * sin(rad - belta));
                }
                //遍历中心线，求点是否在靠近中心线
                for(int i = 0; i < _SplitNum; i++)
                {
                    float tmpCos = dot(float2(LP.x, LP.y), CenterLineArray[i]);
                    if(tmpCos < cos(SplitAngle))
                    {
                            
                    }
                    else
                    {
                        
                    }
                }
                //-------------------theta end--------------------------//
                //向下传递参数
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

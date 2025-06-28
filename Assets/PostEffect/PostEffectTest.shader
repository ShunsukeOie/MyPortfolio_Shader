Shader "Unlit/PostEffectTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Intensity ("Aberration Intensity", Range(0, 0.1)) = 0.01   // ずらす強さ
        _Mode ("Mode", Float) = 0
    }
    SubShader
    {
        // 深度テストやライティングを無効にする
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Intensity;
            float _Mode;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {


                //------------------------------------------------
                // グレースケールの処理
                //------------------------------------------------

                // 色収差の値を返す
                if(_Mode == 0.0)
                {
                    //------------------------------------------------
                    // 色収差の処理
                    //------------------------------------------------
                    float2 uv = i.uv;
                    // 画面中心からのベクトルを計算
                    float2 fromCenter = uv - 0.5;

                    // R、G、BそれぞれのUVをずらす
                    float2 uv_r = uv - fromCenter * _Intensity;
                    float2 uv_g = uv;
                    float2 uv_b = uv + fromCenter * _Intensity;

                    // ずらしたUVで色を取得
                    fixed r = tex2D(_MainTex, uv_r).r;
                    fixed g = tex2D(_MainTex, uv_g).g;
                    fixed b = tex2D(_MainTex, uv_b).b;

                    // 色収差の最終カラー
                    fixed4 chromaticColor = fixed4(r, g, b, 1.0);

                    // 合成して返す
                    return fixed4(r, g, b, 1.0); 
                }
                // グレースケールの値を返す
                else if(_Mode == 1.0)
                {
                    // 元の画面の色を取得
                    fixed4 col = tex2D(_MainTex, i.uv);
                    // RGB値から輝度(明るさ)を計算して、白黒にする
                    float grayscale = dot(col.rgb, float3(0.299, 0.587, 0.114));
                    // 計算した白黒の色を返す
                    return fixed4(grayscale, grayscale, grayscale, col.a);
                }
                // 色収差とグレースケールの両方を計算した値を返す
                else 
                {
                    //------------------------------------------------
                    // 色収差の処理
                    //------------------------------------------------
                    float2 uv = i.uv;
                    // 画面中心からのベクトルを計算
                    float2 fromCenter = uv - 0.5;

                    // R、G、BそれぞれのUVをずらす
                    float2 uv_r = uv - fromCenter * _Intensity;
                    float2 uv_g = uv;
                    float2 uv_b = uv + fromCenter * _Intensity;

                    // ずらしたUVで色を取得
                    fixed r = tex2D(_MainTex, uv_r).r;
                    fixed g = tex2D(_MainTex, uv_g).g;
                    fixed b = tex2D(_MainTex, uv_b).b;

                    // 色収差の最終カラー
                    fixed4 chromaticColor = fixed4(r, g, b, 1.0);

                    // RGB値から輝度（明るさ）を計算して、白黒にする
                    float grayscale = dot(chromaticColor.rgb, float3(0.299, 0.587, 0.114));
                    // 計算した白黒の色を返す
                    return fixed4(grayscale, grayscale, grayscale, 1.0);
                }
            }
            ENDCG
        }
    }
}

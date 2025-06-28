Shader "Unlit/Wipe"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WipeSize("Wipe Size", Float) = 0
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
            #pragma shader_feature\
                WIPE_CIRCLE                 /* 円形 */     \                
                WIPE_LINEAR                 /* リニア */   \                
                WIPE_STRIPES_VERTICAL       /* 縦縞 */     \      
                WIPE_STRIPES_HORIZONTAL     /* 横縞 */     \   
                WIPE_CHECKERBOARD           /* チェッカーボード */           

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

            float _WipeSize;        // ワイプのサイズ
            float2 _WipeCenter;     // 0～1のuv空間での中心座標
            float _AspectRatio;     // アスペクト比
            float2 _WipeDirection;  // ワイプの方向
            float _BlockSize;       // 縞模様用のブロックサイズ

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 円形ワイプ
                #ifdef WIPE_CIRCLE

                    // アスペクト比補正
                    float aspect = _AspectRatio;
                    float2 centerdUV = i.uv - _WipeCenter;
                    centerdUV.x *= aspect;

                    // ワイプの中心からピクセルの距離を計算
                    float dist = length(centerdUV);

                    // ピクセルキル
                    clip(dist - _WipeSize);

                #endif

                // リニアワイプ
                #ifdef WIPE_LINEAR
                    
                    float2 dir = normalize(_WipeDirection);
                    float wipeProgress = dot(dir, i.uv);

                    // ピクセルキル
                    clip(wipeProgress - _WipeSize);

                #endif

                // 縦縞ワイプ
                #ifdef WIPE_STRIPES_VERTICAL
                    
                    // 全て同時ではなく、段々にワイプしていく処理
                    /*/ テクスチャの幅（ピクセル数）からピクセル単位のX座標に変換
                    float pixelX = i.uv.x * _MainTex_TexelSize.z;
                    // どの縞か分かる
                    float stripeIndex = floor(pixelX / _BlockSize);

                    float localX = fmod(pixelX, _BlockSize);
                    float localProgress = localX / _BlockSize;

                    float stripeDelay = stripeIndex * 0.1 ;

                    float threshold = _WipeSize - stripeDelay;

                    clip(localProgress - threshold);*/

                    // テクスチャの幅（ピクセル数）からピクセル単位のX座標に変換
                    float pixelX = i.uv.x * _MainTex_TexelSize.z;

                    // ピクセルのX座標を割った余りとワイプサイズを利用してピクセルキル
                    float localX = fmod(pixelX, _BlockSize);
                    // _WipeSizeが0～1の値のため合わせるために正規化する
                    float wiepProgress = localX / _BlockSize;
                    clip(wiepProgress - _WipeSize);

                #endif

                // 横縞ワイプ
                #ifdef WIPE_STRIPES_HORIZONTAL

                    // テクスチャの幅（ピクセル数）からピクセル単位のY座標に変換
                    float pixelY = i.uv.y * _MainTex_TexelSize.w;
                    
                    // ピクセルのY座標を割った余りとワイプサイズを利用してピクセルキル
                    float localY = fmod(pixelY, _BlockSize);
                    // _WipeSizeが0～1の値のため合わせるために正規化する
                    float wiepProgress = localY / _BlockSize;
                    clip(wiepProgress - _WipeSize);

                #endif

                // チェッカーボードワイプ
                #ifdef WIPE_CHECKERBOARD

                    // テクスチャの幅（ピクセル数）からピクセル単位のX座標に変換
                    float pixelX = i.uv.x * _MainTex_TexelSize.z;
                    // テクスチャの幅（ピクセル数）からピクセル単位のY座標に変換
                    float pixelY = i.uv.y * _MainTex_TexelSize.w;

                    // 行番号を求めて、奇数偶数を判別する
                    float row = floor(pixelY / _BlockSize);
                    float offset = fmod(row, 2.0);

                    // 奇数行ならX座標をずらす
                    float checkerX = fmod(pixelX + (_BlockSize / 2.0) * offset, _BlockSize);

                    // _WipeSizeが0～1の値のため合わせるために正規化する
                    float wiepProgress = checkerX / _BlockSize;

                    // ピクセルキル
                    clip(wiepProgress - _WipeSize);

                #endif

                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}

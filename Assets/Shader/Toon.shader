Shader "Unlit/Toon"
{
    // Unity上でやり取りをするプロパティ情報
    // マテリアルのInspectorウィンドウ上に表示され、スクリプト上からも設定出来る
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightColor ("Light Color", Color) = (1, 1, 1, 1)

        [Header(Shadow)]
        _ShadeMid ("Middle Shadow Color", Color) = (0.8, 0.8, 0.8, 1)   // 1影のカラー
        _ShadeDark ("Dark Shadow Color", Color) = (0.5, 0.5, 0.5, 1)    // 2影のカラー
        _Threshold1 ("Mid Threshold", Range(0, 1)) = 0.5                // 1影のしきい値
        _Threshold2 ("Dark Threshold", Range(0, 1)) = 0.2               // 2影のしきい値

        [Header(Shadow Blur)]
        _ShadowBlur ("Shadow Blur", Range(0, 0.1)) = 0.05  // 影の境界のぼかし幅

        [Header(Skin Settings)]
        _SubsurfaceColor ("Subsurface Color", Color) = (1, 0.4, 0.2, 1) // 肌の内部を透過する光の色（オレンジ系）
        _SubsurfaceIntensity ("Subsurface Intensity", Range(0, 1)) = 0.1// 赤みの強さ

        [Header(Additional Light Settings)]
        _AddLightIntensity ("Additional Light Intensity", Range(0, 5)) = 1  // 追加ライトの光の影響度

        _SpecularGloss ("Specular Gloss", Range(1, 256)) = 20       // ハイライトの鋭さ・光沢の強さ

        [Header(Highlight)]
        _HighlightColor ("Highlight Color", Color) = (1, 1, 1, 1)       // ハイライトのカラー
        _HighlighThreshold ("HighlighThreshold", Range(0, 1)) = 0.7     // ハイライトのしきい値
        _HighlighSmoothness ("highlight Smoothness", Range(0.01, 0.5)) = 0.1    // ハイライトの滑らかさ

        _FacelightIntensity ("Facelight Intensity", Range(0, 1)) = 0.5  // 顔のライト

        [Header(Rimlight)]
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)               // リムライトのカラー
        _RimPower ("Rim Power", Range(1, 10)) = 4                   // リムライトの強さ
        _RimIntensity ("Rim Intensity", Range(0, 2)) = 1            // リムライトの光の強度

        [Header(Outline)]
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)       // アウトラインのカラー
        _OutlineWidth ("Outline Width", Range(0.0, 0.005)) = 0.003  // アウトラインの大きさ

        [Header(ShaderMode)]
        _ShaderMode ("Shader Mode", Float) = 0  // 0：Default、1：Face、2：Eye、3：Cloth

        [Header(AlphaCut)]
        _AlphaCutoff ("Alpha Cutoff", Range(0, 1)) = 0.5    // VRoid特有の服などの余分な黒い部分を削除する
    }
    // サブシェーダー
    // シェーダーの主な処理はこの中に記述する
    // サブシェーダーは複数書くことも可能だが、基本は一つ
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        // セルフシャドウ用パス
        // シャドウマップ用の深度を生成するパス
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM       // プログラムを書き始めるという宣言
            // 関数宣言
            #pragma vertex vertShadow     // "vert"関数を頂点シェーダー使用する宣言
            #pragma fragment fragShadow   // "frag"関数をフラグメントシェーダーと使用する宣言
            #pragma target 3.0
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _AlphaCutoff;

            // 頂点のごとの情報を受け取る構造体
            struct appdata
            {
                float4 vertex : POSITION;   // 頂点
                float3 normal : NORMAL;     // 法線
                float2 uv : TEXCOORD0;      // UV座標
            };

            // vertex to fragment
            struct v2f
            {
                V2F_SHADOW_CASTER;
                float2 uv : TEXCOORD1;  // フラグメントシェーダーにuvを渡す
            };

            // 頂点シェーダー
            v2f vertShadow (appdata v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                o.uv = v.uv;    // uvをv2fにコピー
                return o;
            }

            // フラグメントシェーダー
	        float4 fragShadow(v2f i) : SV_Target
	        {
                // アルファでクリッピング
                float alpha = tex2D(_MainTex, i.uv).a;
                clip(alpha - _AlphaCutoff);

		        SHADOW_CASTER_FRAGMENT(i);
	        }
            ENDCG
        }

        // パス
        // １つのオブジェクトの１度の描画で行う処理をここに書く
        // これも基本一つだが、複雑な描画をするときは複数書くことも可能
        Pass
        {
            Name "ForwardBase"
            Tags { "LightMode" = "ForwardBase" }
            Cull Off // 必ず指定！ 服の裏面とかを表示したいから？

            CGPROGRAM       // プログラムを書き始めるという宣言

            // 関数宣言
            #pragma vertex vert     // "vert"関数を頂点シェーダー使用する宣言
            #pragma fragment frag   // "frag"関数をフラグメントシェーダーと使用する宣言
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fwdadd

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _ShadowMaskTex;

            fixed4 _LightColor;
            fixed4 _ShadeMid;
            float4 _ShadeDark;
            float _Threshold1;
            float _Threshold2;
            
            float _ShadowBlur;

            fixed4 _SubsurfaceColor;
            float _SubsurfaceIntensity;

            fixed4 _HighlightColor;
            float _HighlighThreshold;
            float _HighlighSmoothness;

            float _FacelightIntensity;

            fixed4 _RimColor;
            float _RimPower;
            float _RimIntensity;

            float _ShaderMode;
            float _AlphaCutoff;

            // 頂点のごとの情報を受け取る構造体
            struct appdata
            {
                float4 vertex : POSITION;   // 頂点
                float3 normal : NORMAL;     // 法線
                float2 uv : TEXCOORD0;      // UV座標
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;    // クリッピング空間（画面）に変換された位置
                float4 pos : TEXCOORD1;
                float3 normal : NORMAL;         // ワールド空間の法線
                float2 uv : TEXCOORD0;          // UV座標（そのまま）
                float3 worldPos : TEXCOORD2;
                SHADOW_COORDS(3) // TEXCOORD3をシャドウ様に確保
                // float face : VFACE; // フラグメントシェーダーで受け取ると、表面なら正の値、裏面なら負の値が入る
                // // ラスタライザ段階で生成され、フラグメントシェーダーに直接直接渡される
            };

            // 頂点シェーダー
            v2f vert (appdata v)
            {
                v2f o;
                // クリッピング空間に変換
                o.vertex = UnityObjectToClipPos(v.vertex);
                // 頂点の法線をワールド座標系に変換（ライトの計算のため（ライトがワールド座標））
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.uv;
                o.pos = ComputeScreenPos(o.vertex);
                // シャドウを見る処理
                TRANSFER_SHADOW(o);
                return o;
            }

            // フラグメントシェーダー
            fixed4 frag(v2f i, float face : VFACE) : SV_Target
            {   
                // テクスチャを取得
                fixed3 baseColor = tex2D(_MainTex, i.uv).rgb;
                
                //------------------------------------------------
                // VRoid特有の服などの余分な黒い部分を見せなくする処理
                //------------------------------------------------
                float alphatexColor = tex2D(_MainTex,i.uv).a;
                clip(alphatexColor - _AlphaCutoff);

                //------------------------------------------------
                // ディレクションライトの方向を取り出し、正規化
                //------------------------------------------------
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                // カメラからピクセルへの方向ベクトルを使い視線ベクトルを求める
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

                // VFACEを使って法線の向きを決定
                // faceが負なら裏面なので、法線を反転させる
                // ※ライトの計算時にもこの値を使わずにi.normalを使うと裏面に光が最大になったり意図しないものになる
                float3 normalDir = normalize(i.normal) * face;

                // 法線とライトの方向の内積を計算
                float nl = dot(normalDir, lightDir);

                // シャドウ減衰（セルフシャドウ）
                // SHADOW_ATTENUATION(i)この関数は、そのピクセルが影の中にあるかどうかを計算し、
                // その結果を0.0から1.0までの滑らかな数値で返す
                // 1.0：完全に光が当たっている
                // 0.0：完全に影になっている
                float shadowAtten = SHADOW_ATTENUATION(i);

                // 影をくっきりさせる処理
                shadowAtten = step(0.5, shadowAtten);

                // ライト強度にシャドウ適用
                float lit = max(0, nl) * shadowAtten;

                // スキンシェーディング用の変数
                fixed3 skinShade = fixed3(0, 0, 0);

                // シェーダーモード別に処理を分ける
                if (_ShaderMode == 0.0)
                {
                    // 肌：SSSを実装
                    // 標準的なトゥーンライティング計算
                    lit = max(0, nl) * shadowAtten;

                    //------------------------------------------------
                    // スキンシェーディング（肌の赤み）の実装
                    //------------------------------------------------
                    // 髪の影の中では肌の赤みが出ないように、ShadowAttenを乗算
                    // 影になっている部分ほど、また光が当たっている面程強くなる係数を計算
                    float subsurfaceFactor = saturate(nl);
                    skinShade = _SubsurfaceColor.rgb * subsurfaceFactor * _SubsurfaceIntensity * shadowAtten;
                }
                else if(_ShaderMode == 1.0)
                {
                    //------------------------------------------------
                    // 顔ライティング専用ロジック
                    //------------------------------------------------
                    // メインライトによる陰影（ディレクショナルライトの光）
                    float mainLightStrength = saturate(nl);

                    // 顔用の補助光を計算
                    float faceLightStrength = saturate(dot(normalDir, viewDir) * _FacelightIntensity);
                    // シーンの環境光の明るさを補助光に乗算（これで暗い場所では補助光も弱くなる）
                    faceLightStrength *= length(unity_AmbientSky.rgb);

                    // メインの光と補助光を合成
                    float combinedLight = mainLightStrength + faceLightStrength;

                    // 最後に髪の毛などのセルフシャドウを適用
                    // これにより、どんなに明るくても髪の影は必ず落ちる
                    lit = combinedLight * shadowAtten;

                    //------------------------------------------------
                    // スキンシェーディング（肌の赤み）の実装
                    //------------------------------------------------
                    // 髪の影の中では肌の赤みが出ないように、ShadowAttenを乗算
                    // 影になっている部分ほど、また光が当たっている面程強くなる係数を計算
                    float subsurfaceFactor = saturate(nl);
                    // 最終的な肌の陰影を計算
                    skinShade = _SubsurfaceColor.rgb * subsurfaceFactor * _SubsurfaceIntensity * shadowAtten;
                }
                else if(_ShaderMode == 2.0)
                {
                    // 目：完全に影なし
                    lit = 1.0;
                }
                else if(_ShaderMode == 3.0)
                {
                    // 服：最小の明るさを保証
                    lit = max(0, nl) * shadowAtten;
                    lit = max(lit, 0.3);    
                }
                else
                {
                    // 標準的なトゥーンライティング計算
                    lit = max(0, nl) * shadowAtten;
                }

                //------------------------------------------------
                // 環境光の実装
                //------------------------------------------------
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // 環境光の影響を足す
                lit += dot(ambient, normalDir) * 0.5;   // 0.5は強さ調整、要調整

                //------------------------------------------------
                // 影の実装
                //------------------------------------------------
                // 段階的な陰影
                /* litの値に基づいて、1影と2影の割合を滑らかに計算
                _Threshold1：光と1影の境界
                _Threshold2：1影と2影の境界
                _ShadowBlur：ぼかし幅
                smoothstep(min, max, value)
                valueがminとmaxの間にあるとき、0.0から1.0へ滑らかに変化する値を返す*/
                float shadeFactor1 = smoothstep(_Threshold2 - _ShadowBlur, _Threshold2 + _ShadowBlur, lit);
                float shadeFactor2 = smoothstep(_Threshold1 - _ShadowBlur, _Threshold1 + _ShadowBlur, lit);

                // 2つの影色（暗い影と中間影）をブレンド
                // lerp(色A,色B,割合t)
                // tが0.0なら色A、tが1.0なら色B、tが0.5なら半分ずつ混ざった色
                fixed3 shade = lerp(_ShadeDark.rgb, _ShadeMid.rgb, shadeFactor1);
                // さらに明るい色とブレンド
                shade = lerp(shade, _LightColor.rgb, shadeFactor2);

                //------------------------------------------------
                // ハイライトの実装
                //------------------------------------------------
                // ライト方向との内積を計算
                float highlightDot = dot(normalDir, normalize(viewDir));
                highlightDot = 1.0 - highlightDot;  // カメラに正対しているほど大きく

                // 滑らかなしきい値で明るさを決定
                float highlightFactor = smoothstep(
                    _HighlighThreshold - _HighlighSmoothness, 
                    _HighlighThreshold + _HighlighSmoothness,
                    highlightDot
                );
                fixed3 highlight = highlightFactor * _HighlightColor.rgb;

                //------------------------------------------------
                // リムライトの実装
                //------------------------------------------------
                // サーフェイスの法線と光の入射方向に依存するリムの強さを求める
                float rim = 1.0 - saturate(dot(viewDir, normalDir));
                // pow()を使用して、強さの変化を指数関数的にする
                rim = pow(rim, _RimPower);
                // 最終的なリムの色と光を決定
                fixed3 rimLight = rim * _RimColor.rgb * _RimIntensity;

                //------------------------------------------------
                // テクスチャカラーに乗算
                //------------------------------------------------
                fixed3 finalColor = baseColor * shade + highlight + rimLight + skinShade;

                return fixed4(finalColor, 1.0);
            }
            ENDCG
        }

        // 2つ目以降のライトの光を描画するためのパス
        // 複数のライトの影響を個別に加算する
        Pass
        {
            // ライトを1個ずつ描画して足していく
            Name "ForwardAdd"
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One // ライトの加算合成。ForwardBaseで描画された色の上に足されていく

            CGPROGRAM
            #pragma vertex vertAdd
            #pragma fragment fragAdd
            #pragma multi_compile_fwdadd_fullshadows

            #include "UnityCG.cginc"
            #include "Lighting.cginc" // ライトの色や方向などのプロパティを定義している
            #include "AutoLight.cginc"// ライトの減衰やシャドウに関する機能を提供している

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Threshold1;
            float _ShadowBlur;
            float _SpecularGloss;
            float _AlphaCutoff;
            float _AddLightIntensity;   // 光の影響度を変更する変数
            float _ShaderMode;
            
            // 頂点のごとの情報を受け取る構造体
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2fadd
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                LIGHTING_COORDS(3, 4)  // ライト減衰用の座標を確保(TEXCOORD3, 4を使用)
            };

            // 頂点シェーダー
            v2fadd vertAdd (appdata v)
            {
                v2fadd o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_VERTEX_TO_FRAGMENT(o); // ライト減衰計算に必要な情報をv2fに渡す
                return o;
            }

            fixed4 fragAdd(v2fadd i) : SV_Target
            {
                //------------------------------------------------
                // VRoid特有の服などの余分な黒い部分を見せなくする処理
                //------------------------------------------------
                float alphatexColor = tex2D(_MainTex,i.uv).a;
                clip(alphatexColor - _AlphaCutoff);

                //------------------------------------------------
                // 変数の準備
                //------------------------------------------------
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                float3 normal = normalize(i.normal);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

                // 両面描画（Cull Off）に対応するため、裏面では法線を反転させる
                if(dot(normal, viewDir) < 0.0f)
                {
                    normal = -normal;
                }

                //------------------------------------------------
                // ライティング計算
                //------------------------------------------------
                // ライトの減衰
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);

                fixed3 finalColor;

                // 顔モードの場合滑らかな光だけを加算する
                if(_ShaderMode == 1.0)
                {
                    // リアルな拡散反射を計算し、パキッとした影は付けない
                    float diff = saturate(dot(normal, lightDir));
                    finalColor = diff * _LightColor0 * tex2D(_MainTex, i.uv).rgb;
                    // 減衰を適用
                    finalColor *= attenuation;
                }
                // 顔以外はトゥーンライティング
                else
                {
                    // 追加ライトによる光の強度を計算
                    float nl = dot(normal, lightDir);
                    float add_lit = saturate(nl) * attenuation;

                    // トゥーン的な陰影を計算（光が当たる部分だけを描画）
                    // ForwardBaseで使った閾値とぼかし幅を流用
                    float lightFactor = smoothstep(_Threshold1 - _ShadowBlur, _Threshold1 + _ShadowBlur, add_lit);
                    fixed3 diffuseColor = lightFactor * _LightColor0.rgb;

                    // トゥーン的なハイライトを計算
                    float3 halfDir = normalize(lightDir + viewDir);
                    float specFactor = pow(saturate(dot(normal, halfDir)), _SpecularGloss);
                    // stepでハイライトをくっきりさせる
                    fixed3 specularColor = step(0.95, specFactor) * _LightColor0.rgb;

                    // テクスチャカラーと合成
                    finalColor = (diffuseColor + specularColor) * tex2D(_MainTex, i.uv).rgb;
                }

                // 最終的にライトの強度を乗算して返す
                return fixed4(finalColor * _AddLightIntensity, 1.0);
            }
            ENDCG
        }

        // アウトライン用パス
        // 輪郭を少し大きく描いてそれを黒く塗りアウトラインっぽく見せる
        Pass
        {
            Name "OUTLINE"
            Cull Front  // 前面をカリング

            CGPROGRAM       // プログラムを書き始めるという宣言
            // 関数宣言
            #pragma vertex vertOutline     // "vert"関数を頂点シェーダー使用する宣言
            #pragma fragment fragOutline   // "frag"関数をフラグメントシェーダーと使用する宣言

            #include "UnityCG.cginc"

            fixed4 _OutlineColor;
            float _OutlineWidth;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AlphaCutoff;

            // 頂点のごとの情報を受け取る構造体
            struct appdata
            {
                float4 vertex : POSITION;   // 頂点
                float3 normal : NORMAL;     // 法線
                float2 uv : TEXCOORD0;      // UV座標
            };

            // vertex to fragment
            struct v2f
            {
                float4 vertex : SV_POSITION;    // クリッピング空間（画面）に変換された位置
                float2 uv : TEXCOORD0;          // UV座標（そのまま）
            };

            // 頂点シェーダー
            v2f vertOutline (appdata v)
            {
                v2f o;
                // 頂点を法線方向に拡大
                float3 norm = normalize(v.normal);
                v.vertex.xyz += norm * _OutlineWidth;

                // クリッピング空間に変換
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // フラグメントシェーダー
            fixed4 fragOutline(v2f i) : SV_Target
            {
                // 余分な黒い部分に合わせてアウトラインが生成されてしまうためその分を削除する
                float alpha = tex2D(_MainTex, i.uv).a;
                clip(alpha - _AlphaCutoff);

                return _OutlineColor;
            }
            ENDCG
        }
    }
}

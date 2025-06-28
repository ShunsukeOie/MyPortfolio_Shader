Shader "Unlit/Toon"
{
    // Unity��ł���������v���p�e�B���
    // �}�e���A����Inspector�E�B���h�E��ɕ\������A�X�N���v�g�ォ����ݒ�o����
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightColor ("Light Color", Color) = (1, 1, 1, 1)

        [Header(Shadow)]
        _ShadeMid ("Middle Shadow Color", Color) = (0.8, 0.8, 0.8, 1)   // 1�e�̃J���[
        _ShadeDark ("Dark Shadow Color", Color) = (0.5, 0.5, 0.5, 1)    // 2�e�̃J���[
        _Threshold1 ("Mid Threshold", Range(0, 1)) = 0.5                // 1�e�̂������l
        _Threshold2 ("Dark Threshold", Range(0, 1)) = 0.2               // 2�e�̂������l

        [Header(Shadow Blur)]
        _ShadowBlur ("Shadow Blur", Range(0, 0.1)) = 0.05  // �e�̋��E�̂ڂ�����

        [Header(Skin Settings)]
        _SubsurfaceColor ("Subsurface Color", Color) = (1, 0.4, 0.2, 1) // ���̓����𓧉߂�����̐F�i�I�����W�n�j
        _SubsurfaceIntensity ("Subsurface Intensity", Range(0, 1)) = 0.1// �Ԃ݂̋���

        [Header(Additional Light Settings)]
        _AddLightIntensity ("Additional Light Intensity", Range(0, 5)) = 1  // �ǉ����C�g�̌��̉e���x

        _SpecularGloss ("Specular Gloss", Range(1, 256)) = 20       // �n�C���C�g�̉s���E����̋���

        [Header(Highlight)]
        _HighlightColor ("Highlight Color", Color) = (1, 1, 1, 1)       // �n�C���C�g�̃J���[
        _HighlighThreshold ("HighlighThreshold", Range(0, 1)) = 0.7     // �n�C���C�g�̂������l
        _HighlighSmoothness ("highlight Smoothness", Range(0.01, 0.5)) = 0.1    // �n�C���C�g�̊��炩��

        _FacelightIntensity ("Facelight Intensity", Range(0, 1)) = 0.5  // ��̃��C�g

        [Header(Rimlight)]
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)               // �������C�g�̃J���[
        _RimPower ("Rim Power", Range(1, 10)) = 4                   // �������C�g�̋���
        _RimIntensity ("Rim Intensity", Range(0, 2)) = 1            // �������C�g�̌��̋��x

        [Header(Outline)]
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)       // �A�E�g���C���̃J���[
        _OutlineWidth ("Outline Width", Range(0.0, 0.005)) = 0.003  // �A�E�g���C���̑傫��

        [Header(ShaderMode)]
        _ShaderMode ("Shader Mode", Float) = 0  // 0�FDefault�A1�FFace�A2�FEye�A3�FCloth

        [Header(AlphaCut)]
        _AlphaCutoff ("Alpha Cutoff", Range(0, 1)) = 0.5    // VRoid���L�̕��Ȃǂ̗]���ȍ����������폜����
    }
    // �T�u�V�F�[�_�[
    // �V�F�[�_�[�̎�ȏ����͂��̒��ɋL�q����
    // �T�u�V�F�[�_�[�͕����������Ƃ��\�����A��{�͈��
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        // �Z���t�V���h�E�p�p�X
        // �V���h�E�}�b�v�p�̐[�x�𐶐�����p�X
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM       // �v���O�����������n�߂�Ƃ����錾
            // �֐��錾
            #pragma vertex vertShadow     // "vert"�֐��𒸓_�V�F�[�_�[�g�p����錾
            #pragma fragment fragShadow   // "frag"�֐����t���O�����g�V�F�[�_�[�Ǝg�p����錾
            #pragma target 3.0
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _AlphaCutoff;

            // ���_�̂��Ƃ̏����󂯎��\����
            struct appdata
            {
                float4 vertex : POSITION;   // ���_
                float3 normal : NORMAL;     // �@��
                float2 uv : TEXCOORD0;      // UV���W
            };

            // vertex to fragment
            struct v2f
            {
                V2F_SHADOW_CASTER;
                float2 uv : TEXCOORD1;  // �t���O�����g�V�F�[�_�[��uv��n��
            };

            // ���_�V�F�[�_�[
            v2f vertShadow (appdata v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                o.uv = v.uv;    // uv��v2f�ɃR�s�[
                return o;
            }

            // �t���O�����g�V�F�[�_�[
	        float4 fragShadow(v2f i) : SV_Target
	        {
                // �A���t�@�ŃN���b�s���O
                float alpha = tex2D(_MainTex, i.uv).a;
                clip(alpha - _AlphaCutoff);

		        SHADOW_CASTER_FRAGMENT(i);
	        }
            ENDCG
        }

        // �p�X
        // �P�̃I�u�W�F�N�g�̂P�x�̕`��ōs�������������ɏ���
        // �������{������A���G�ȕ`�������Ƃ��͕����������Ƃ��\
        Pass
        {
            Name "ForwardBase"
            Tags { "LightMode" = "ForwardBase" }
            Cull Off // �K���w��I ���̗��ʂƂ���\������������H

            CGPROGRAM       // �v���O�����������n�߂�Ƃ����錾

            // �֐��錾
            #pragma vertex vert     // "vert"�֐��𒸓_�V�F�[�_�[�g�p����錾
            #pragma fragment frag   // "frag"�֐����t���O�����g�V�F�[�_�[�Ǝg�p����錾
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

            // ���_�̂��Ƃ̏����󂯎��\����
            struct appdata
            {
                float4 vertex : POSITION;   // ���_
                float3 normal : NORMAL;     // �@��
                float2 uv : TEXCOORD0;      // UV���W
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;    // �N���b�s���O��ԁi��ʁj�ɕϊ����ꂽ�ʒu
                float4 pos : TEXCOORD1;
                float3 normal : NORMAL;         // ���[���h��Ԃ̖@��
                float2 uv : TEXCOORD0;          // UV���W�i���̂܂܁j
                float3 worldPos : TEXCOORD2;
                SHADOW_COORDS(3) // TEXCOORD3���V���h�E�l�Ɋm��
                // float face : VFACE; // �t���O�����g�V�F�[�_�[�Ŏ󂯎��ƁA�\�ʂȂ琳�̒l�A���ʂȂ畉�̒l������
                // // ���X�^���C�U�i�K�Ő�������A�t���O�����g�V�F�[�_�[�ɒ��ڒ��ړn�����
            };

            // ���_�V�F�[�_�[
            v2f vert (appdata v)
            {
                v2f o;
                // �N���b�s���O��Ԃɕϊ�
                o.vertex = UnityObjectToClipPos(v.vertex);
                // ���_�̖@�������[���h���W�n�ɕϊ��i���C�g�̌v�Z�̂��߁i���C�g�����[���h���W�j�j
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.uv;
                o.pos = ComputeScreenPos(o.vertex);
                // �V���h�E�����鏈��
                TRANSFER_SHADOW(o);
                return o;
            }

            // �t���O�����g�V�F�[�_�[
            fixed4 frag(v2f i, float face : VFACE) : SV_Target
            {   
                // �e�N�X�`�����擾
                fixed3 baseColor = tex2D(_MainTex, i.uv).rgb;
                
                //------------------------------------------------
                // VRoid���L�̕��Ȃǂ̗]���ȍ��������������Ȃ����鏈��
                //------------------------------------------------
                float alphatexColor = tex2D(_MainTex,i.uv).a;
                clip(alphatexColor - _AlphaCutoff);

                //------------------------------------------------
                // �f�B���N�V�������C�g�̕��������o���A���K��
                //------------------------------------------------
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                // �J��������s�N�Z���ւ̕����x�N�g�����g�������x�N�g�������߂�
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

                // VFACE���g���Ė@���̌���������
                // face�����Ȃ痠�ʂȂ̂ŁA�@���𔽓]������
                // �����C�g�̌v�Z���ɂ����̒l���g�킸��i.normal���g���Ɨ��ʂɌ����ő�ɂȂ�����Ӑ}���Ȃ����̂ɂȂ�
                float3 normalDir = normalize(i.normal) * face;

                // �@���ƃ��C�g�̕����̓��ς��v�Z
                float nl = dot(normalDir, lightDir);

                // �V���h�E�����i�Z���t�V���h�E�j
                // SHADOW_ATTENUATION(i)���̊֐��́A���̃s�N�Z�����e�̒��ɂ��邩�ǂ������v�Z���A
                // ���̌��ʂ�0.0����1.0�܂ł̊��炩�Ȑ��l�ŕԂ�
                // 1.0�F���S�Ɍ����������Ă���
                // 0.0�F���S�ɉe�ɂȂ��Ă���
                float shadowAtten = SHADOW_ATTENUATION(i);

                // �e���������肳���鏈��
                shadowAtten = step(0.5, shadowAtten);

                // ���C�g���x�ɃV���h�E�K�p
                float lit = max(0, nl) * shadowAtten;

                // �X�L���V�F�[�f�B���O�p�̕ϐ�
                fixed3 skinShade = fixed3(0, 0, 0);

                // �V�F�[�_�[���[�h�ʂɏ����𕪂���
                if (_ShaderMode == 0.0)
                {
                    // ���FSSS������
                    // �W���I�ȃg�D�[�����C�e�B���O�v�Z
                    lit = max(0, nl) * shadowAtten;

                    //------------------------------------------------
                    // �X�L���V�F�[�f�B���O�i���̐Ԃ݁j�̎���
                    //------------------------------------------------
                    // ���̉e�̒��ł͔��̐Ԃ݂��o�Ȃ��悤�ɁAShadowAtten����Z
                    // �e�ɂȂ��Ă��镔���قǁA�܂������������Ă���ʒ������Ȃ�W�����v�Z
                    float subsurfaceFactor = saturate(nl);
                    skinShade = _SubsurfaceColor.rgb * subsurfaceFactor * _SubsurfaceIntensity * shadowAtten;
                }
                else if(_ShaderMode == 1.0)
                {
                    //------------------------------------------------
                    // �烉�C�e�B���O��p���W�b�N
                    //------------------------------------------------
                    // ���C�����C�g�ɂ��A�e�i�f�B���N�V���i�����C�g�̌��j
                    float mainLightStrength = saturate(nl);

                    // ��p�̕⏕�����v�Z
                    float faceLightStrength = saturate(dot(normalDir, viewDir) * _FacelightIntensity);
                    // �V�[���̊����̖��邳��⏕���ɏ�Z�i����ňÂ��ꏊ�ł͕⏕�����キ�Ȃ�j
                    faceLightStrength *= length(unity_AmbientSky.rgb);

                    // ���C���̌��ƕ⏕��������
                    float combinedLight = mainLightStrength + faceLightStrength;

                    // �Ō�ɔ��̖тȂǂ̃Z���t�V���h�E��K�p
                    // ����ɂ��A�ǂ�Ȃɖ��邭�Ă����̉e�͕K��������
                    lit = combinedLight * shadowAtten;

                    //------------------------------------------------
                    // �X�L���V�F�[�f�B���O�i���̐Ԃ݁j�̎���
                    //------------------------------------------------
                    // ���̉e�̒��ł͔��̐Ԃ݂��o�Ȃ��悤�ɁAShadowAtten����Z
                    // �e�ɂȂ��Ă��镔���قǁA�܂������������Ă���ʒ������Ȃ�W�����v�Z
                    float subsurfaceFactor = saturate(nl);
                    // �ŏI�I�Ȕ��̉A�e���v�Z
                    skinShade = _SubsurfaceColor.rgb * subsurfaceFactor * _SubsurfaceIntensity * shadowAtten;
                }
                else if(_ShaderMode == 2.0)
                {
                    // �ځF���S�ɉe�Ȃ�
                    lit = 1.0;
                }
                else if(_ShaderMode == 3.0)
                {
                    // ���F�ŏ��̖��邳��ۏ�
                    lit = max(0, nl) * shadowAtten;
                    lit = max(lit, 0.3);    
                }
                else
                {
                    // �W���I�ȃg�D�[�����C�e�B���O�v�Z
                    lit = max(0, nl) * shadowAtten;
                }

                //------------------------------------------------
                // �����̎���
                //------------------------------------------------
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // �����̉e���𑫂�
                lit += dot(ambient, normalDir) * 0.5;   // 0.5�͋��������A�v����

                //------------------------------------------------
                // �e�̎���
                //------------------------------------------------
                // �i�K�I�ȉA�e
                /* lit�̒l�Ɋ�Â��āA1�e��2�e�̊��������炩�Ɍv�Z
                _Threshold1�F����1�e�̋��E
                _Threshold2�F1�e��2�e�̋��E
                _ShadowBlur�F�ڂ�����
                smoothstep(min, max, value)
                value��min��max�̊Ԃɂ���Ƃ��A0.0����1.0�֊��炩�ɕω�����l��Ԃ�*/
                float shadeFactor1 = smoothstep(_Threshold2 - _ShadowBlur, _Threshold2 + _ShadowBlur, lit);
                float shadeFactor2 = smoothstep(_Threshold1 - _ShadowBlur, _Threshold1 + _ShadowBlur, lit);

                // 2�̉e�F�i�Â��e�ƒ��ԉe�j���u�����h
                // lerp(�FA,�FB,����t)
                // t��0.0�Ȃ�FA�At��1.0�Ȃ�FB�At��0.5�Ȃ甼�������������F
                fixed3 shade = lerp(_ShadeDark.rgb, _ShadeMid.rgb, shadeFactor1);
                // ����ɖ��邢�F�ƃu�����h
                shade = lerp(shade, _LightColor.rgb, shadeFactor2);

                //------------------------------------------------
                // �n�C���C�g�̎���
                //------------------------------------------------
                // ���C�g�����Ƃ̓��ς��v�Z
                float highlightDot = dot(normalDir, normalize(viewDir));
                highlightDot = 1.0 - highlightDot;  // �J�����ɐ��΂��Ă���قǑ傫��

                // ���炩�Ȃ������l�Ŗ��邳������
                float highlightFactor = smoothstep(
                    _HighlighThreshold - _HighlighSmoothness, 
                    _HighlighThreshold + _HighlighSmoothness,
                    highlightDot
                );
                fixed3 highlight = highlightFactor * _HighlightColor.rgb;

                //------------------------------------------------
                // �������C�g�̎���
                //------------------------------------------------
                // �T�[�t�F�C�X�̖@���ƌ��̓��˕����Ɉˑ����郊���̋��������߂�
                float rim = 1.0 - saturate(dot(viewDir, normalDir));
                // pow()���g�p���āA�����̕ω����w���֐��I�ɂ���
                rim = pow(rim, _RimPower);
                // �ŏI�I�ȃ����̐F�ƌ�������
                fixed3 rimLight = rim * _RimColor.rgb * _RimIntensity;

                //------------------------------------------------
                // �e�N�X�`���J���[�ɏ�Z
                //------------------------------------------------
                fixed3 finalColor = baseColor * shade + highlight + rimLight + skinShade;

                return fixed4(finalColor, 1.0);
            }
            ENDCG
        }

        // 2�ڈȍ~�̃��C�g�̌���`�悷�邽�߂̃p�X
        // �����̃��C�g�̉e�����ʂɉ��Z����
        Pass
        {
            // ���C�g��1���`�悵�đ����Ă���
            Name "ForwardAdd"
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One // ���C�g�̉��Z�����BForwardBase�ŕ`�悳�ꂽ�F�̏�ɑ�����Ă���

            CGPROGRAM
            #pragma vertex vertAdd
            #pragma fragment fragAdd
            #pragma multi_compile_fwdadd_fullshadows

            #include "UnityCG.cginc"
            #include "Lighting.cginc" // ���C�g�̐F������Ȃǂ̃v���p�e�B���`���Ă���
            #include "AutoLight.cginc"// ���C�g�̌�����V���h�E�Ɋւ���@�\��񋟂��Ă���

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Threshold1;
            float _ShadowBlur;
            float _SpecularGloss;
            float _AlphaCutoff;
            float _AddLightIntensity;   // ���̉e���x��ύX����ϐ�
            float _ShaderMode;
            
            // ���_�̂��Ƃ̏����󂯎��\����
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
                LIGHTING_COORDS(3, 4)  // ���C�g�����p�̍��W���m��(TEXCOORD3, 4���g�p)
            };

            // ���_�V�F�[�_�[
            v2fadd vertAdd (appdata v)
            {
                v2fadd o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_VERTEX_TO_FRAGMENT(o); // ���C�g�����v�Z�ɕK�v�ȏ���v2f�ɓn��
                return o;
            }

            fixed4 fragAdd(v2fadd i) : SV_Target
            {
                //------------------------------------------------
                // VRoid���L�̕��Ȃǂ̗]���ȍ��������������Ȃ����鏈��
                //------------------------------------------------
                float alphatexColor = tex2D(_MainTex,i.uv).a;
                clip(alphatexColor - _AlphaCutoff);

                //------------------------------------------------
                // �ϐ��̏���
                //------------------------------------------------
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                float3 normal = normalize(i.normal);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

                // ���ʕ`��iCull Off�j�ɑΉ����邽�߁A���ʂł͖@���𔽓]������
                if(dot(normal, viewDir) < 0.0f)
                {
                    normal = -normal;
                }

                //------------------------------------------------
                // ���C�e�B���O�v�Z
                //------------------------------------------------
                // ���C�g�̌���
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);

                fixed3 finalColor;

                // �烂�[�h�̏ꍇ���炩�Ȍ����������Z����
                if(_ShaderMode == 1.0)
                {
                    // ���A���Ȋg�U���˂��v�Z���A�p�L�b�Ƃ����e�͕t���Ȃ�
                    float diff = saturate(dot(normal, lightDir));
                    finalColor = diff * _LightColor0 * tex2D(_MainTex, i.uv).rgb;
                    // ������K�p
                    finalColor *= attenuation;
                }
                // ��ȊO�̓g�D�[�����C�e�B���O
                else
                {
                    // �ǉ����C�g�ɂ����̋��x���v�Z
                    float nl = dot(normal, lightDir);
                    float add_lit = saturate(nl) * attenuation;

                    // �g�D�[���I�ȉA�e���v�Z�i���������镔��������`��j
                    // ForwardBase�Ŏg����臒l�Ƃڂ������𗬗p
                    float lightFactor = smoothstep(_Threshold1 - _ShadowBlur, _Threshold1 + _ShadowBlur, add_lit);
                    fixed3 diffuseColor = lightFactor * _LightColor0.rgb;

                    // �g�D�[���I�ȃn�C���C�g���v�Z
                    float3 halfDir = normalize(lightDir + viewDir);
                    float specFactor = pow(saturate(dot(normal, halfDir)), _SpecularGloss);
                    // step�Ńn�C���C�g���������肳����
                    fixed3 specularColor = step(0.95, specFactor) * _LightColor0.rgb;

                    // �e�N�X�`���J���[�ƍ���
                    finalColor = (diffuseColor + specularColor) * tex2D(_MainTex, i.uv).rgb;
                }

                // �ŏI�I�Ƀ��C�g�̋��x����Z���ĕԂ�
                return fixed4(finalColor * _AddLightIntensity, 1.0);
            }
            ENDCG
        }

        // �A�E�g���C���p�p�X
        // �֊s�������傫���`���Ă���������h��A�E�g���C�����ۂ�������
        Pass
        {
            Name "OUTLINE"
            Cull Front  // �O�ʂ��J�����O

            CGPROGRAM       // �v���O�����������n�߂�Ƃ����錾
            // �֐��錾
            #pragma vertex vertOutline     // "vert"�֐��𒸓_�V�F�[�_�[�g�p����錾
            #pragma fragment fragOutline   // "frag"�֐����t���O�����g�V�F�[�_�[�Ǝg�p����錾

            #include "UnityCG.cginc"

            fixed4 _OutlineColor;
            float _OutlineWidth;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AlphaCutoff;

            // ���_�̂��Ƃ̏����󂯎��\����
            struct appdata
            {
                float4 vertex : POSITION;   // ���_
                float3 normal : NORMAL;     // �@��
                float2 uv : TEXCOORD0;      // UV���W
            };

            // vertex to fragment
            struct v2f
            {
                float4 vertex : SV_POSITION;    // �N���b�s���O��ԁi��ʁj�ɕϊ����ꂽ�ʒu
                float2 uv : TEXCOORD0;          // UV���W�i���̂܂܁j
            };

            // ���_�V�F�[�_�[
            v2f vertOutline (appdata v)
            {
                v2f o;
                // ���_��@�������Ɋg��
                float3 norm = normalize(v.normal);
                v.vertex.xyz += norm * _OutlineWidth;

                // �N���b�s���O��Ԃɕϊ�
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // �t���O�����g�V�F�[�_�[
            fixed4 fragOutline(v2f i) : SV_Target
            {
                // �]���ȍ��������ɍ��킹�ăA�E�g���C������������Ă��܂����߂��̕����폜����
                float alpha = tex2D(_MainTex, i.uv).a;
                clip(alpha - _AlphaCutoff);

                return _OutlineColor;
            }
            ENDCG
        }
    }
}

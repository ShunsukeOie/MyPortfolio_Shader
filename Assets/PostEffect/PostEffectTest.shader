Shader "Unlit/PostEffectTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Intensity ("Aberration Intensity", Range(0, 0.1)) = 0.01   // ���炷����
        _Mode ("Mode", Float) = 0
    }
    SubShader
    {
        // �[�x�e�X�g�⃉�C�e�B���O�𖳌��ɂ���
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
                // �O���[�X�P�[���̏���
                //------------------------------------------------

                // �F�����̒l��Ԃ�
                if(_Mode == 0.0)
                {
                    //------------------------------------------------
                    // �F�����̏���
                    //------------------------------------------------
                    float2 uv = i.uv;
                    // ��ʒ��S����̃x�N�g�����v�Z
                    float2 fromCenter = uv - 0.5;

                    // R�AG�AB���ꂼ���UV�����炷
                    float2 uv_r = uv - fromCenter * _Intensity;
                    float2 uv_g = uv;
                    float2 uv_b = uv + fromCenter * _Intensity;

                    // ���炵��UV�ŐF���擾
                    fixed r = tex2D(_MainTex, uv_r).r;
                    fixed g = tex2D(_MainTex, uv_g).g;
                    fixed b = tex2D(_MainTex, uv_b).b;

                    // �F�����̍ŏI�J���[
                    fixed4 chromaticColor = fixed4(r, g, b, 1.0);

                    // �������ĕԂ�
                    return fixed4(r, g, b, 1.0); 
                }
                // �O���[�X�P�[���̒l��Ԃ�
                else if(_Mode == 1.0)
                {
                    // ���̉�ʂ̐F���擾
                    fixed4 col = tex2D(_MainTex, i.uv);
                    // RGB�l����P�x(���邳)���v�Z���āA�����ɂ���
                    float grayscale = dot(col.rgb, float3(0.299, 0.587, 0.114));
                    // �v�Z���������̐F��Ԃ�
                    return fixed4(grayscale, grayscale, grayscale, col.a);
                }
                // �F�����ƃO���[�X�P�[���̗������v�Z�����l��Ԃ�
                else 
                {
                    //------------------------------------------------
                    // �F�����̏���
                    //------------------------------------------------
                    float2 uv = i.uv;
                    // ��ʒ��S����̃x�N�g�����v�Z
                    float2 fromCenter = uv - 0.5;

                    // R�AG�AB���ꂼ���UV�����炷
                    float2 uv_r = uv - fromCenter * _Intensity;
                    float2 uv_g = uv;
                    float2 uv_b = uv + fromCenter * _Intensity;

                    // ���炵��UV�ŐF���擾
                    fixed r = tex2D(_MainTex, uv_r).r;
                    fixed g = tex2D(_MainTex, uv_g).g;
                    fixed b = tex2D(_MainTex, uv_b).b;

                    // �F�����̍ŏI�J���[
                    fixed4 chromaticColor = fixed4(r, g, b, 1.0);

                    // RGB�l����P�x�i���邳�j���v�Z���āA�����ɂ���
                    float grayscale = dot(chromaticColor.rgb, float3(0.299, 0.587, 0.114));
                    // �v�Z���������̐F��Ԃ�
                    return fixed4(grayscale, grayscale, grayscale, 1.0);
                }
            }
            ENDCG
        }
    }
}

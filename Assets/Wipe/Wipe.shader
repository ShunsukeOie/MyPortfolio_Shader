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
                WIPE_CIRCLE                 /* �~�` */     \                
                WIPE_LINEAR                 /* ���j�A */   \                
                WIPE_STRIPES_VERTICAL       /* �c�� */     \      
                WIPE_STRIPES_HORIZONTAL     /* ���� */     \   
                WIPE_CHECKERBOARD           /* �`�F�b�J�[�{�[�h */           

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

            float _WipeSize;        // ���C�v�̃T�C�Y
            float2 _WipeCenter;     // 0�`1��uv��Ԃł̒��S���W
            float _AspectRatio;     // �A�X�y�N�g��
            float2 _WipeDirection;  // ���C�v�̕���
            float _BlockSize;       // �Ȗ͗l�p�̃u���b�N�T�C�Y

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
                // �~�`���C�v
                #ifdef WIPE_CIRCLE

                    // �A�X�y�N�g��␳
                    float aspect = _AspectRatio;
                    float2 centerdUV = i.uv - _WipeCenter;
                    centerdUV.x *= aspect;

                    // ���C�v�̒��S����s�N�Z���̋������v�Z
                    float dist = length(centerdUV);

                    // �s�N�Z���L��
                    clip(dist - _WipeSize);

                #endif

                // ���j�A���C�v
                #ifdef WIPE_LINEAR
                    
                    float2 dir = normalize(_WipeDirection);
                    float wipeProgress = dot(dir, i.uv);

                    // �s�N�Z���L��
                    clip(wipeProgress - _WipeSize);

                #endif

                // �c�ȃ��C�v
                #ifdef WIPE_STRIPES_VERTICAL
                    
                    // �S�ē����ł͂Ȃ��A�i�X�Ƀ��C�v���Ă�������
                    /*/ �e�N�X�`���̕��i�s�N�Z�����j����s�N�Z���P�ʂ�X���W�ɕϊ�
                    float pixelX = i.uv.x * _MainTex_TexelSize.z;
                    // �ǂ̎Ȃ�������
                    float stripeIndex = floor(pixelX / _BlockSize);

                    float localX = fmod(pixelX, _BlockSize);
                    float localProgress = localX / _BlockSize;

                    float stripeDelay = stripeIndex * 0.1 ;

                    float threshold = _WipeSize - stripeDelay;

                    clip(localProgress - threshold);*/

                    // �e�N�X�`���̕��i�s�N�Z�����j����s�N�Z���P�ʂ�X���W�ɕϊ�
                    float pixelX = i.uv.x * _MainTex_TexelSize.z;

                    // �s�N�Z����X���W���������]��ƃ��C�v�T�C�Y�𗘗p���ăs�N�Z���L��
                    float localX = fmod(pixelX, _BlockSize);
                    // _WipeSize��0�`1�̒l�̂��ߍ��킹�邽�߂ɐ��K������
                    float wiepProgress = localX / _BlockSize;
                    clip(wiepProgress - _WipeSize);

                #endif

                // ���ȃ��C�v
                #ifdef WIPE_STRIPES_HORIZONTAL

                    // �e�N�X�`���̕��i�s�N�Z�����j����s�N�Z���P�ʂ�Y���W�ɕϊ�
                    float pixelY = i.uv.y * _MainTex_TexelSize.w;
                    
                    // �s�N�Z����Y���W���������]��ƃ��C�v�T�C�Y�𗘗p���ăs�N�Z���L��
                    float localY = fmod(pixelY, _BlockSize);
                    // _WipeSize��0�`1�̒l�̂��ߍ��킹�邽�߂ɐ��K������
                    float wiepProgress = localY / _BlockSize;
                    clip(wiepProgress - _WipeSize);

                #endif

                // �`�F�b�J�[�{�[�h���C�v
                #ifdef WIPE_CHECKERBOARD

                    // �e�N�X�`���̕��i�s�N�Z�����j����s�N�Z���P�ʂ�X���W�ɕϊ�
                    float pixelX = i.uv.x * _MainTex_TexelSize.z;
                    // �e�N�X�`���̕��i�s�N�Z�����j����s�N�Z���P�ʂ�Y���W�ɕϊ�
                    float pixelY = i.uv.y * _MainTex_TexelSize.w;

                    // �s�ԍ������߂āA������𔻕ʂ���
                    float row = floor(pixelY / _BlockSize);
                    float offset = fmod(row, 2.0);

                    // ��s�Ȃ�X���W�����炷
                    float checkerX = fmod(pixelX + (_BlockSize / 2.0) * offset, _BlockSize);

                    // _WipeSize��0�`1�̒l�̂��ߍ��킹�邽�߂ɐ��K������
                    float wiepProgress = checkerX / _BlockSize;

                    // �s�N�Z���L��
                    clip(wiepProgress - _WipeSize);

                #endif

                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}

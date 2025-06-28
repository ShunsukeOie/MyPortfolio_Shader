using UnityEngine;

[ExecuteInEditMode]     // �G�f�B�^��ł����ʂ��m�F�ł���悤�ɂ��邨�܂��Ȃ�
public class PostEffectTest : MonoBehaviour
{
    public Material effectMaterial;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (effectMaterial != null)
        {
            // source�i���̉摜�j���AeffectMaterial���g���ĉ��H���Adestination�i�ŏI��ʁj�ɏ����o��
            Graphics.Blit(source, destination, effectMaterial);
        }
        else
        {
            // �}�e���A�����Ȃ���Ή������Ȃ�
            Graphics.Blit(source, destination);
        }
    }   
}

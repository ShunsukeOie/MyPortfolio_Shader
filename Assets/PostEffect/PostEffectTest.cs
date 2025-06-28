using UnityEngine;

[ExecuteInEditMode]     // エディタ上でも効果を確認できるようにするおまじない
public class PostEffectTest : MonoBehaviour
{
    public Material effectMaterial;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (effectMaterial != null)
        {
            // source（元の画像）を、effectMaterialを使って加工し、destination（最終画面）に書き出す
            Graphics.Blit(source, destination, effectMaterial);
        }
        else
        {
            // マテリアルがなければ何もしない
            Graphics.Blit(source, destination);
        }
    }   
}

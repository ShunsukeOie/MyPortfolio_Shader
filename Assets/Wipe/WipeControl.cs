using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

// ワイプの種類
public enum WipeType
{
    Circle,             // 円ワイプ
    Linear,             // リニアワイプ
    Stripes_Vertical,   // 縦縞ワイプ
    Stripes_Horizontal, // 横縞ワイプ
    CheckerBoard,       // チェッカーボードワイプ
}

// ワイプのパラメーター
public struct WipeParam
{
    public Vector2 wipeDir;
    public float wipeSize;
}

public class WipeControl : MonoBehaviour
{
    [SerializeField, Header("ワイプのタイプ")]
    private WipeType m_wipeType = WipeType.Circle;
    [SerializeField, Header("ワイプに渡すマテリアル")]
    private Material m_wipeMaterial;
    [SerializeField, Header("ワイプするスピード")]
    private float m_wipeSpeed = 0.5f;

    private WipeParam m_wipeParam;

    [SerializeField, Header("リニアワイプの方向")]
    private Vector2 m_wipeDir = new Vector2(1.0f, 1.0f);

    [SerializeField]
    private float m_blockSize = 128.0f;

    // イメージ
    [SerializeField]
    private RawImage targetImage;

    // ワイプ完了までの最大値
    private const float WIPE_MAX_SIZE = 1.5f;

    // Start is called before the first frame update
    void Start()
    {
        m_wipeParam.wipeDir = m_wipeDir;
        m_wipeParam.wipeDir.Normalize();

        m_wipeParam.wipeSize = 0.0f;

        // イメージにマテリアルを設定
        targetImage.material = m_wipeMaterial;


        // イメージの中心からワイプさせる為に必要な処理
        // RectTransformのTransformを取得
        RectTransform rt = targetImage.rectTransform;

        // アスペクト比を計算し、シェーダーに渡す
        float aspect = rt.rect.width / rt.rect.height;
        m_wipeMaterial.SetFloat("_AspectRatio", aspect);
        
        // マテリアル情報をシェーダーに渡す
        m_wipeMaterial.SetVector("_WipeCenter", new Vector4(0.5f, 0.5f, 0f, 0f));
    }

    // Update is called once per frame
    void Update()
    {
        // ワイプ完了までの最大値より小さいときのみ
        if(m_wipeParam.wipeSize <= WIPE_MAX_SIZE)
        {
            // ワイプサイズを加算する
            m_wipeParam.wipeSize += m_wipeSpeed * Time.deltaTime;

            // ワイプサイズをシェーダーに渡す
            m_wipeMaterial.SetFloat("_WipeSize", m_wipeParam.wipeSize);

            switch (m_wipeType)
            {
                // 円形ワイプ
                case WipeType.Circle:
                    // キーワードを使いシェーダー側の分岐処理を切り替える
                    SetWipeKeyword("WIPE_CIRCLE");
                    break;

                // リニアワイプ
                case WipeType.Linear:
                    // ワイプする方向をシェーダーに渡す
                    m_wipeMaterial.SetVector("_WipeDirection", m_wipeParam.wipeDir);
                    // キーワードを使いシェーダー側の分岐処理を切り替える
                    SetWipeKeyword("WIPE_LINEAR");
                    break;

                // 縦縞ワイプ
                case WipeType.Stripes_Vertical:
                    Debug.Log(m_wipeParam.wipeSize);
                    // ブロックサイズをシェーダーに渡す
                    m_wipeMaterial.SetFloat("_BlockSize", m_blockSize);
                    // キーワードを使いシェーダー側の分岐処理を切り替える
                    SetWipeKeyword("WIPE_STRIPES_VERTICAL");
                    break;

                // 横縞ワイプ
                case WipeType.Stripes_Horizontal:
                    // ブロックサイズをシェーダーに渡す
                    m_wipeMaterial.SetFloat("_BlockSize", m_blockSize);
                    // キーワードを使いシェーダー側の分岐処理を切り替える
                    SetWipeKeyword("WIPE_STRIPES_HORIZONTAL");
                    break;

                // チェッカーボードワイプ
                case WipeType.CheckerBoard:
                    // ブロックサイズをシェーダーに渡す
                    m_wipeMaterial.SetFloat("_BlockSize", m_blockSize);
                    // キーワードを使いシェーダー側の分岐処理を切り替える
                    SetWipeKeyword("WIPE_CHECKERBOARD");
                    break;
            }


        }

    }

    // シェーダーに渡すキーワードを切り替える
    void SetWipeKeyword(string keyword)
    {
        string[] allKeywords =
        {
            "WIPE_CIRCLE",
            "WIPE_LINEAR",
            "WIPE_STRIPES_VERTICAL",
            "WIPE_STRIPES_HORIZONTAL",
            "WIPE_CHECKERBOARD"
        };

        foreach(string k in allKeywords)
        {
            m_wipeMaterial.DisableKeyword(k);
        }
        m_wipeMaterial.EnableKeyword(keyword);
    }
}

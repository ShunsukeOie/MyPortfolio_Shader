using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

// ���C�v�̎��
public enum WipeType
{
    Circle,             // �~���C�v
    Linear,             // ���j�A���C�v
    Stripes_Vertical,   // �c�ȃ��C�v
    Stripes_Horizontal, // ���ȃ��C�v
    CheckerBoard,       // �`�F�b�J�[�{�[�h���C�v
}

// ���C�v�̃p�����[�^�[
public struct WipeParam
{
    public Vector2 wipeDir;
    public float wipeSize;
}

public class WipeControl : MonoBehaviour
{
    [SerializeField, Header("���C�v�̃^�C�v")]
    private WipeType m_wipeType = WipeType.Circle;
    [SerializeField, Header("���C�v�ɓn���}�e���A��")]
    private Material m_wipeMaterial;
    [SerializeField, Header("���C�v����X�s�[�h")]
    private float m_wipeSpeed = 0.5f;

    private WipeParam m_wipeParam;

    [SerializeField, Header("���j�A���C�v�̕���")]
    private Vector2 m_wipeDir = new Vector2(1.0f, 1.0f);

    [SerializeField]
    private float m_blockSize = 128.0f;

    // �C���[�W
    [SerializeField]
    private RawImage targetImage;

    // ���C�v�����܂ł̍ő�l
    private const float WIPE_MAX_SIZE = 1.5f;

    // Start is called before the first frame update
    void Start()
    {
        m_wipeParam.wipeDir = m_wipeDir;
        m_wipeParam.wipeDir.Normalize();

        m_wipeParam.wipeSize = 0.0f;

        // �C���[�W�Ƀ}�e���A����ݒ�
        targetImage.material = m_wipeMaterial;


        // �C���[�W�̒��S���烏�C�v������ׂɕK�v�ȏ���
        // RectTransform��Transform���擾
        RectTransform rt = targetImage.rectTransform;

        // �A�X�y�N�g����v�Z���A�V�F�[�_�[�ɓn��
        float aspect = rt.rect.width / rt.rect.height;
        m_wipeMaterial.SetFloat("_AspectRatio", aspect);
        
        // �}�e���A�������V�F�[�_�[�ɓn��
        m_wipeMaterial.SetVector("_WipeCenter", new Vector4(0.5f, 0.5f, 0f, 0f));
    }

    // Update is called once per frame
    void Update()
    {
        // ���C�v�����܂ł̍ő�l��菬�����Ƃ��̂�
        if(m_wipeParam.wipeSize <= WIPE_MAX_SIZE)
        {
            // ���C�v�T�C�Y�����Z����
            m_wipeParam.wipeSize += m_wipeSpeed * Time.deltaTime;

            // ���C�v�T�C�Y���V�F�[�_�[�ɓn��
            m_wipeMaterial.SetFloat("_WipeSize", m_wipeParam.wipeSize);

            switch (m_wipeType)
            {
                // �~�`���C�v
                case WipeType.Circle:
                    // �L�[���[�h���g���V�F�[�_�[���̕��򏈗���؂�ւ���
                    SetWipeKeyword("WIPE_CIRCLE");
                    break;

                // ���j�A���C�v
                case WipeType.Linear:
                    // ���C�v����������V�F�[�_�[�ɓn��
                    m_wipeMaterial.SetVector("_WipeDirection", m_wipeParam.wipeDir);
                    // �L�[���[�h���g���V�F�[�_�[���̕��򏈗���؂�ւ���
                    SetWipeKeyword("WIPE_LINEAR");
                    break;

                // �c�ȃ��C�v
                case WipeType.Stripes_Vertical:
                    Debug.Log(m_wipeParam.wipeSize);
                    // �u���b�N�T�C�Y���V�F�[�_�[�ɓn��
                    m_wipeMaterial.SetFloat("_BlockSize", m_blockSize);
                    // �L�[���[�h���g���V�F�[�_�[���̕��򏈗���؂�ւ���
                    SetWipeKeyword("WIPE_STRIPES_VERTICAL");
                    break;

                // ���ȃ��C�v
                case WipeType.Stripes_Horizontal:
                    // �u���b�N�T�C�Y���V�F�[�_�[�ɓn��
                    m_wipeMaterial.SetFloat("_BlockSize", m_blockSize);
                    // �L�[���[�h���g���V�F�[�_�[���̕��򏈗���؂�ւ���
                    SetWipeKeyword("WIPE_STRIPES_HORIZONTAL");
                    break;

                // �`�F�b�J�[�{�[�h���C�v
                case WipeType.CheckerBoard:
                    // �u���b�N�T�C�Y���V�F�[�_�[�ɓn��
                    m_wipeMaterial.SetFloat("_BlockSize", m_blockSize);
                    // �L�[���[�h���g���V�F�[�_�[���̕��򏈗���؂�ւ���
                    SetWipeKeyword("WIPE_CHECKERBOARD");
                    break;
            }


        }

    }

    // �V�F�[�_�[�ɓn���L�[���[�h��؂�ւ���
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

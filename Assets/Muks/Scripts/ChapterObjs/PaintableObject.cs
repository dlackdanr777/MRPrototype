using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PaintableObject : MonoBehaviour, IChapterObject
{
    [SerializeField] private Transform _player;
    [SerializeField] private Material _originalMaterial; // ���� ��Ƽ����
    [SerializeField] private RenderTexture _renderTexture; // ���� �ؽ�ó

    private Material _instanceMaterial; // �ν��Ͻ�ȭ�� ��Ƽ����


    public void Enabled(ChapterManager manager)
    {
        transform.position = manager.GetFloorCenterPos() + new Vector3(0, transform.localScale.y * 0.5f, 0);
        Vector3 dir = (_player.transform.position - transform.position).normalized;
        dir.y = 0;
        Quaternion targetRotation = Quaternion.LookRotation(dir, Vector3.up);
        transform.rotation = targetRotation;
        ClearRenderTexture(Color.white);
    }

    public void Disabled(ChapterManager manager)
    {
    }


    private void Start()
    {
        // ���� ��Ƽ������ �ν��Ͻ�ȭ
        _instanceMaterial = new Material(_originalMaterial);

        // �� ������Ʈ�� Renderer�� �ν��Ͻ� ��Ƽ���� ����
        Renderer renderer = GetComponent<Renderer>();
        if (renderer != null)
        {
            renderer.material = _instanceMaterial;
        }

        // ���� �ؽ�ó �ʱ�ȭ
        InitRenderTexture();
    }

    /// <summary>
    /// RenderTexture �ʱ�ȭ
    /// </summary>
    private void InitRenderTexture()
    {
        if (_renderTexture != null)
        {
            _renderTexture.Release(); // ���� ���� �ؽ�ó ����
        }

        // RenderTexture ����
        _renderTexture = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGB32);
        _renderTexture.Create();

        // RenderTexture�� �ν��Ͻ� ��Ƽ���� ����
        if (_instanceMaterial != null)
        {
            _instanceMaterial.SetTexture("_MainTex", _renderTexture);
        }

        // �ʱ�ȭ �������� Ŭ����
        ClearRenderTexture(Color.white);
    }

    /// <summary>
    /// RenderTexture�� Ư�� �������� Ŭ����
    /// </summary>
    private void ClearRenderTexture(Color clearColor)
    {
        if (_renderTexture == null)
        {
            Debug.LogWarning("RenderTexture is not initialized.");
            return;
        }

        RenderTexture.active = _renderTexture;
        GL.Clear(true, true, clearColor);
        RenderTexture.active = null;
    }

    /// <summary>
    /// UV ��ǥ�� ������� ����Ʈ�� ����
    /// </summary>
    public void ApplyPaint(Vector2 uvCoord, Material paintMaterial, Color color, float brushSize)
    {
        if (_renderTexture == null)
        {
            Debug.LogError("RenderTexture is not initialized. Cannot apply paint.");
            return;
        }

        RenderTexture.active = _renderTexture;
        GL.PushMatrix();
        GL.LoadPixelMatrix(0, _renderTexture.width, 0, _renderTexture.height);

        // �귯�� ���� �� �׸���
        Texture2D brush = CreateBrush(color, brushSize);
        Rect brushRect = new Rect(
            uvCoord.x * _renderTexture.width - brush.width * 0.5f,
            uvCoord.y * _renderTexture.height - brush.height * 0.5f,
            brush.width,
            brush.height
        );
        Graphics.DrawTexture(brushRect, brush);

        GL.PopMatrix();
        RenderTexture.active = null;
    }

    /// <summary>
    /// �귯�� �ؽ�ó ����
    /// </summary>
    private Texture2D CreateBrush(Color color, float size)
    {
        int brushSize = Mathf.RoundToInt(size * 1024);
        Texture2D texture = new Texture2D(brushSize, brushSize, TextureFormat.ARGB32, false);

        Vector2 center = new Vector2(brushSize / 2f, brushSize / 2f); // �귯�� �߽�

        for (int y = 0; y < brushSize; y++)
        {
            for (int x = 0; x < brushSize; x++)
            {
                // �ȼ��� �߽ɿ����� �Ÿ� ���
                float distance = Vector2.Distance(new Vector2(x, y), center);
                float maxDistance = brushSize / 2f;

                // ���� ���� �Ÿ� ������� ���� (�߽��� 1, �ܰ��� 0)
                float alpha = Mathf.Clamp01(1f - (distance / maxDistance));

                // �ȼ� ���� ���� (���� ����)
                texture.SetPixel(x, y, new Color(color.r, color.g, color.b, alpha));
            }
        }

        texture.Apply();
        return texture;
    }
}
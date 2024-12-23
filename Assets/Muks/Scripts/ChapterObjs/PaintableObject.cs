using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PaintableObject : MonoBehaviour, IChapterObject
{
    [SerializeField] private Transform _player;
    [SerializeField] private Material _originalMaterial; // 원본 머티리얼
    [SerializeField] private RenderTexture _renderTexture; // 렌더 텍스처

    private Material _instanceMaterial; // 인스턴스화된 머티리얼


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
        // 원본 머티리얼을 인스턴스화
        _instanceMaterial = new Material(_originalMaterial);

        // 이 오브젝트의 Renderer에 인스턴스 머티리얼 적용
        Renderer renderer = GetComponent<Renderer>();
        if (renderer != null)
        {
            renderer.material = _instanceMaterial;
        }

        // 렌더 텍스처 초기화
        InitRenderTexture();
    }

    /// <summary>
    /// RenderTexture 초기화
    /// </summary>
    private void InitRenderTexture()
    {
        if (_renderTexture != null)
        {
            _renderTexture.Release(); // 기존 렌더 텍스처 해제
        }

        // RenderTexture 생성
        _renderTexture = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGB32);
        _renderTexture.Create();

        // RenderTexture를 인스턴스 머티리얼에 설정
        if (_instanceMaterial != null)
        {
            _instanceMaterial.SetTexture("_MainTex", _renderTexture);
        }

        // 초기화 색상으로 클리어
        ClearRenderTexture(Color.white);
    }

    /// <summary>
    /// RenderTexture를 특정 색상으로 클리어
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
    /// UV 좌표를 기반으로 페인트를 적용
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

        // 브러시 생성 및 그리기
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
    /// 브러시 텍스처 생성
    /// </summary>
    private Texture2D CreateBrush(Color color, float size)
    {
        int brushSize = Mathf.RoundToInt(size * 1024);
        Texture2D texture = new Texture2D(brushSize, brushSize, TextureFormat.ARGB32, false);

        Vector2 center = new Vector2(brushSize / 2f, brushSize / 2f); // 브러시 중심

        for (int y = 0; y < brushSize; y++)
        {
            for (int x = 0; x < brushSize; x++)
            {
                // 픽셀의 중심에서의 거리 계산
                float distance = Vector2.Distance(new Vector2(x, y), center);
                float maxDistance = brushSize / 2f;

                // 알파 값을 거리 기반으로 감소 (중심은 1, 외곽은 0)
                float alpha = Mathf.Clamp01(1f - (distance / maxDistance));

                // 픽셀 색상 설정 (알파 적용)
                texture.SetPixel(x, y, new Color(color.r, color.g, color.b, alpha));
            }
        }

        texture.Apply();
        return texture;
    }
}
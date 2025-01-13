using Meta.XR.MRUtilityKit;
using Oculus.Interaction;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PaintableObject : MonoBehaviour, IChapterObject
{
    [SerializeField] private Transform _player;
    [SerializeField] private GameObject _sketchImage;
    [SerializeField] private Material _originalMaterial; // ���� ��Ƽ����

    private RenderTexture _renderTexture; // ���� �ؽ�ó
    private Material _instanceMaterial; // �ν��Ͻ�ȭ�� ��Ƽ����
    private Vector3 _tmpSketchScale;


    public void Enabled(ChapterManager manager)
    {
        transform.position = manager.GetFloorCenterPos() + new Vector3(0, transform.localScale.y * 0.5f, 0);
        Vector3 dir = (_player.transform.position - transform.position).normalized;
        dir.y = 0;
        Quaternion targetRotation = Quaternion.LookRotation(dir, Vector3.up);
        transform.rotation = targetRotation;
        ClearRenderTexture(Color.white);
        AdjustToLargestWall(manager);

        if (_sketchImage != null)
        {
            // 1. �θ� ������ ��������
            Transform sketchTransform = _sketchImage.transform;
            Vector3 parentScale = sketchTransform.parent != null
                ? sketchTransform.parent.lossyScale
                : Vector3.one;

            // 2. Y �������� �ڽ� ������ ���� (1:1 ���� ����)
            Vector3 newLocalScale = new Vector3(0.7f, 0.7f, 1f); // �ڽ��� �⺻ ����
            float adjustedYScale = parentScale.y * newLocalScale.y; // �θ� Y �ݿ�
            newLocalScale.x = adjustedYScale; // X�� Y�� ����
            newLocalScale.y = adjustedYScale; // Y �״�� ����

            // 3. ������ ����
            sketchTransform.localScale = new Vector3(
                newLocalScale.x / parentScale.x,
                newLocalScale.y / parentScale.y,
                sketchTransform.localScale.z // Z�� �ʿ��ϸ� ���������� ���� ����
            );
        }
    }

    public void Disabled(ChapterManager manager)
    {
    }


    private void Awake()
    {
        if (_sketchImage != null)
        {
            _tmpSketchScale = _sketchImage.transform.localScale;
        }
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


    private void AdjustToLargestWall(ChapterManager manager)
    {
        MRUKRoom room = manager.GetRoom();
        if (room == null || room.WallAnchors == null || room.WallAnchors.Count == 0)
        {
            Debug.LogError("No walls found in the room.");
            return;
        }

        // ������ ���� ���� �� ã��
        MRUKAnchor largestWall = null;
        float largestArea = 0;

        foreach (var wall in room.WallAnchors)
        {
            // PlaneBoundary2D�� �ִ��� Ȯ��
            List<Vector2> planeBoundary = wall.PlaneBoundary2D; // PlaneBoundary2D�� wall���� �����´ٰ� ����
            if (planeBoundary == null || planeBoundary.Count < 3) // �ٰ����� �ּ� 3���� ���� �ʿ�
            {
                Debug.LogWarning($"Wall {wall.name} does not have a valid PlaneBoundary2D.");
                continue;
            }

            // ���� ���
            float area = CalculatePolygonArea(planeBoundary);
            if (area > largestArea)
            {
                largestArea = area;
                largestWall = wall;
            }
        }

        if (largestWall == null)
        {
            Debug.LogError("No valid wall with a PlaneBoundary2D was found.");
            return;
        }

        // ���� ū ���� PlaneBoundary2D�� ���� ������Ʈ ũ�� ����
        List<Vector2> largestBoundary = largestWall.PlaneBoundary2D;
        Bounds bounds = GetBoundsFromBoundary(largestBoundary);

        // ������Ʈ ũ�� ����
        transform.localScale = new Vector3(bounds.size.x, bounds.size.y, 0.01f);
        transform.position = largestWall.transform.position;
        transform.rotation = largestWall.transform.rotation;
        Debug.Log($"Object scaled to match the largest wall: {largestWall.name} (Area: {largestArea})");
    }



    private float CalculatePolygonArea(List<Vector2> points)
    {
        float area = 0f;

        // Shoelace formula ����
        for (int i = 0; i < points.Count; i++)
        {
            Vector2 current = points[i];
            Vector2 next = points[(i + 1) % points.Count]; // ������ ���� ù ��° �� ����

            area += current.x * next.y - current.y * next.x;
        }

        return Mathf.Abs(area * 0.5f);
    }

    private Bounds GetBoundsFromBoundary(List<Vector2> points)
    {
        if (points == null || points.Count == 0)
            return new Bounds();

        float minX = float.MaxValue, maxX = float.MinValue;
        float minY = float.MaxValue, maxY = float.MinValue;

        foreach (var point in points)
        {
            if (point.x < minX) minX = point.x;
            if (point.x > maxX) maxX = point.x;
            if (point.y < minY) minY = point.y;
            if (point.y > maxY) maxY = point.y;
        }

        Vector3 center = new Vector3((minX + maxX) / 2, (minY + maxY) / 2, 0);
        Vector3 size = new Vector3(maxX - minX, maxY - minY, 0);

        return new Bounds(center, size);
    }
}
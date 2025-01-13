using Meta.XR.MRUtilityKit;
using Oculus.Interaction;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PaintableObject : MonoBehaviour, IChapterObject
{
    [SerializeField] private Transform _player;
    [SerializeField] private GameObject _sketchImage;
    [SerializeField] private Material _originalMaterial; // 원본 머티리얼

    private RenderTexture _renderTexture; // 렌더 텍스처
    private Material _instanceMaterial; // 인스턴스화된 머티리얼
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
            // 1. 부모 스케일 가져오기
            Transform sketchTransform = _sketchImage.transform;
            Vector3 parentScale = sketchTransform.parent != null
                ? sketchTransform.parent.lossyScale
                : Vector3.one;

            // 2. Y 기준으로 자식 스케일 조정 (1:1 비율 유지)
            Vector3 newLocalScale = new Vector3(0.7f, 0.7f, 1f); // 자식의 기본 비율
            float adjustedYScale = parentScale.y * newLocalScale.y; // 부모 Y 반영
            newLocalScale.x = adjustedYScale; // X는 Y와 동일
            newLocalScale.y = adjustedYScale; // Y 그대로 유지

            // 3. 스케일 설정
            sketchTransform.localScale = new Vector3(
                newLocalScale.x / parentScale.x,
                newLocalScale.y / parentScale.y,
                sketchTransform.localScale.z // Z는 필요하면 고정값으로 설정 가능
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


    private void AdjustToLargestWall(ChapterManager manager)
    {
        MRUKRoom room = manager.GetRoom();
        if (room == null || room.WallAnchors == null || room.WallAnchors.Count == 0)
        {
            Debug.LogError("No walls found in the room.");
            return;
        }

        // 면적이 가장 넓은 벽 찾기
        MRUKAnchor largestWall = null;
        float largestArea = 0;

        foreach (var wall in room.WallAnchors)
        {
            // PlaneBoundary2D가 있는지 확인
            List<Vector2> planeBoundary = wall.PlaneBoundary2D; // PlaneBoundary2D가 wall에서 가져온다고 가정
            if (planeBoundary == null || planeBoundary.Count < 3) // 다각형은 최소 3개의 점이 필요
            {
                Debug.LogWarning($"Wall {wall.name} does not have a valid PlaneBoundary2D.");
                continue;
            }

            // 면적 계산
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

        // 가장 큰 벽의 PlaneBoundary2D에 맞춰 오브젝트 크기 조정
        List<Vector2> largestBoundary = largestWall.PlaneBoundary2D;
        Bounds bounds = GetBoundsFromBoundary(largestBoundary);

        // 오브젝트 크기 조정
        transform.localScale = new Vector3(bounds.size.x, bounds.size.y, 0.01f);
        transform.position = largestWall.transform.position;
        transform.rotation = largestWall.transform.rotation;
        Debug.Log($"Object scaled to match the largest wall: {largestWall.name} (Area: {largestArea})");
    }



    private float CalculatePolygonArea(List<Vector2> points)
    {
        float area = 0f;

        // Shoelace formula 적용
        for (int i = 0; i < points.Count; i++)
        {
            Vector2 current = points[i];
            Vector2 next = points[(i + 1) % points.Count]; // 마지막 점과 첫 번째 점 연결

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
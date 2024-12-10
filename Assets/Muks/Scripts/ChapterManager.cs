using Meta.XR.MRUtilityKit;
using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;

public enum Chapter
{
    Chapter1,
    Chapter2,
}

public enum SpawnPositionType
{
    Center,
    CameraForward,
    Corner,
    Random,
    None,
}

[Serializable]
public class ChapterObjectData
{
    [SerializeField] private MonoBehaviour _chapterObject;
    public MonoBehaviour ChapterObject => _chapterObject;

    private IChapterObject _iChapterObject;
    public IChapterObject IChapterObject => _iChapterObject;

    public void ConvertToIChapterObject()
    {
        if (_chapterObject is IChapterObject)
        {
            _iChapterObject = _chapterObject as IChapterObject;
        }
        else
        {
            throw new Exception("해당 오브젝트는 IChapterObject를 상속받지 않았습니다: " + _chapterObject.name);
        }
    }
}



[Serializable]
public class ChapterData
{
    [SerializeField] private ChapterObjectData[] _chapterObjects;
    public ChapterObjectData[] ChapterObjects => _chapterObjects;
    public void ConvertToIChapterObject()
    {
        for(int i = 0, cnt = _chapterObjects.Length; i < cnt; ++i)
        {
            _chapterObjects[i].ConvertToIChapterObject();
        }
    }
}



public class ChapterManager : MonoBehaviour
{
    [SerializeField] private FloorDetectManager _floorDetectManager;
    [SerializeField] private MRUK _mruk;
    [SerializeField] private Transform _spawnPos;
    [SerializeField] private ChapterData[] _chapterObjects;

    private Chapter _chapter;
    private MRUKRoom _room;
    private int _index;


    private void Start()
    {
        InitChapterData();
        _index = 0;
    }

    private void InitChapterData()
    {
        for (int i = 0, cntI = _chapterObjects.Length; i < cntI; ++i)
        {
            ChapterData chapterData = _chapterObjects[i];
            chapterData.ConvertToIChapterObject();
            for (int j = 0, cntJ = chapterData.ChapterObjects.Length; j < cntJ; ++j)
            {
                chapterData.ChapterObjects[j].ChapterObject.gameObject.SetActive(false);
                chapterData.ChapterObjects[j].IChapterObject.Disabled(this);
            }
        }
    }



    public void ResetChapter()
    {
        SetChapter(_index);
    }


    public void StartChapter(int chapter)
    {
        _index = chapter;
        SetChapter(_index);
    }


    public void NextChapter()
    {
        _index = (_index + 1) % _chapterObjects.Length;
        SetChapter(_index);
    }

    private void SetChapter(int index)
    {
        _index = Mathf.Clamp(index, 0, _chapterObjects.Length - 1);
        for (int i = 0, cntI = _chapterObjects.Length; i < cntI; ++i)
        {
            for (int j = 0, cntJ = _chapterObjects[i].ChapterObjects.Length; j < cntJ; ++j)
            {
                _chapterObjects[i].ChapterObjects[j].ChapterObject.gameObject.SetActive(false);
                _chapterObjects[i].ChapterObjects[j].IChapterObject.Disabled(this);
            }
        }

        ChapterData currentChapter = _chapterObjects[_index];
        for (int i = 0, cnt = currentChapter.ChapterObjects.Length; i < cnt; ++i)
        {
            ChapterObjectData chapterObjectData = currentChapter.ChapterObjects[i];
            chapterObjectData.IChapterObject.Enabled(this);
            chapterObjectData.ChapterObject.gameObject.SetActive(true);
        }
    }


    public Vector3 GetRandomFloorPos()
    {
        if (_room == null)
            _room = FindAnyObjectByType<MRUKRoom>();

        var floorAnchor = _room.FloorAnchor;

        if (floorAnchor != null && floorAnchor.PlaneBoundary2D != null)
        {
            List<Vector2> planeBoundary = floorAnchor.PlaneBoundary2D;

            if (planeBoundary != null && planeBoundary.Count > 0)
            {
                // 다각형을 삼각형으로 분할
                List<int> triangles = new List<int>();
                TriangulatePolygon(planeBoundary, triangles);

                // 삼각형 선택
                int randomTriangleIndex = UnityEngine.Random.Range(0, triangles.Count / 3);
                Vector2 v0 = planeBoundary[triangles[randomTriangleIndex * 3]];
                Vector2 v1 = planeBoundary[triangles[randomTriangleIndex * 3 + 1]];
                Vector2 v2 = planeBoundary[triangles[randomTriangleIndex * 3 + 2]];

                // 삼각형 내부 랜덤 점 계산
                Vector2 randomPoint2D = GetRandomPointInTriangle(v0, v1, v2);

                // Local 좌표에서 World 좌표로 변환
                Vector3 localRandomPoint = new Vector3(randomPoint2D.x, 0, randomPoint2D.y);
                Vector3 anchorPosition = floorAnchor.transform.position;
                Quaternion anchorRotation = floorAnchor.transform.rotation;
                Vector3 worldRandomPoint = anchorPosition + anchorRotation * localRandomPoint;
                worldRandomPoint.y = floorAnchor.transform.position.y;
                return worldRandomPoint;
            }
            else
            {
                Debug.LogWarning("Plane boundary is empty.");
            }
        }
        else
        {
            Debug.LogError("FloorAnchor or PlaneBoundary2D is null.");
        }

        return GetCameraSpawnPos();
    }


    public Vector3 GetCameraSpawnPos()
    {
        float floorPosY = _floorDetectManager.GetFloorPosY();
        float layLength = 0.7f;
        Vector3 spawnPos = _spawnPos.position + _spawnPos.forward * layLength;
        if (Physics.Raycast(_spawnPos.position, _spawnPos.forward, out RaycastHit hit, layLength))
        {
            Vector3 dirToSpawnPos = (_spawnPos.position - hit.point).normalized;
            spawnPos = hit.point + dirToSpawnPos * 0.1f;
        }
        spawnPos.y = floorPosY <= -1000 ? 0.2f : floorPosY;
        return spawnPos;
    }


    public Vector3 GetFloorCenterPos()
    {
        if (_room == null)
            _room = FindAnyObjectByType<MRUKRoom>();


        var floorAnchor = _room.FloorAnchor;
        return _room.FloorAnchor.transform.position;
    }

    public Vector3 GetRandomCornerPos()
    {
        if (_room == null)
            _room = FindAnyObjectByType<MRUKRoom>();
        var floorAnchor = _room.FloorAnchor;

        if (floorAnchor != null && floorAnchor.PlaneBoundary2D != null)
        {
            List<Vector2> planeBoundary = floorAnchor.PlaneBoundary2D;

            if (planeBoundary != null && planeBoundary.Count > 0)
            {
                Vector3 anchorPosition = floorAnchor.transform.position;
                Quaternion anchorRotation = floorAnchor.transform.rotation;
                List<Vector3> floorCornerPosList = new List<Vector3>();

                for (int i = 0; i < planeBoundary.Count; i++)
                {
                    Vector3 verticalLocalPoint = new Vector3(planeBoundary[i].x, planeBoundary[i].y, 0);
                    Vector3 rotatedLocalPoint = anchorRotation * verticalLocalPoint;
                    Vector3 worldPoint = anchorPosition + rotatedLocalPoint;

                    floorCornerPosList.Add(worldPoint);
                }

                Vector3 randomCorner = floorCornerPosList[UnityEngine.Random.Range(0, floorCornerPosList.Count)];
                return randomCorner;
            }
            else
            {
                Debug.LogWarning("Plane boundary is empty.");
            }
        }
        else
        {
            Debug.LogError("FloorAnchor or PlaneBoundary2D is null.");
        }

        return GetCameraSpawnPos();
    }


    // 삼각형 내부 랜덤 점 생성
    private Vector2 GetRandomPointInTriangle(Vector2 v0, Vector2 v1, Vector2 v2)
    {
        float r1 = Mathf.Sqrt(UnityEngine.Random.value);
        float r2 = UnityEngine.Random.value;

        float a = 1 - r1;
        float b = r1 * (1 - r2);
        float c = r1 * r2;

        return a * v0 + b * v1 + c * v2;
    }

    // 다각형을 삼각형으로 분할
    private void TriangulatePolygon(List<Vector2> vertices, List<int> triangles)
    {
        // UnityEngine.U2D.PolygonUtility 또는 외부 라이브러리를 사용할 수도 있음
        for (int i = 1; i < vertices.Count - 1; i++)
        {
            triangles.Add(0);
            triangles.Add(i);
            triangles.Add(i + 1);
        }
    }
}

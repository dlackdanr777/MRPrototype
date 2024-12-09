using Meta.XR.MRUtilityKit;
using System;
using System.Collections.Generic;
using UnityEngine;

public enum Chapter
{
    Chapter1,
    Chapter2,
}



public class ChapterManager : MonoBehaviour
{
    [SerializeField] private FloorDetectManager _floorDetectManager;
    [SerializeField] private MRUK _mruk;
    [SerializeField] private Transform _spawnPos;
    [SerializeField] private GrabGun _grabGun;
    [SerializeField] private Dog _dog;
    [SerializeField] private GameObject _cat;
    [SerializeField] private Fire _fire;
    [SerializeField] private GameObject _fireExtinguisher;
    [SerializeField] private GameObject _man;
    [SerializeField] private GrabObject _grabObject;

    private Chapter _chapter;
    private MRUKRoom _room;

    private void Start()
    {
        _fire.gameObject.SetActive(false);
        _man.gameObject.SetActive(false);
        _fireExtinguisher.gameObject.SetActive(false);
        _grabGun.gameObject.SetActive(false);
        _dog.gameObject.SetActive(false);
        _cat.gameObject.SetActive(false);
        _grabObject.gameObject.SetActive(false);
    }


    public void ResetChapter()
    {
        switch (_chapter)
        {
            case Chapter.Chapter1:
                StartChapter1();
                break;

                case Chapter.Chapter2:
                StartChapter2(); 
                break;
        }
    }

    public void StartChapter(Chapter chapter)
    {
        if (_chapter == chapter)
            return;

        _chapter = chapter;
        switch (_chapter)
        {
            case Chapter.Chapter1:
                StartChapter1();
                break;

            case Chapter.Chapter2:
                StartChapter2();
                break;
        }
    }

    public void NextChapter()
    {
        int chapterIndex = (int)_chapter;
        int chapterLength = Enum.GetValues(typeof(Chapter)).Length;
        chapterIndex = (chapterIndex + 1) % chapterLength;
        _chapter = (Chapter)chapterIndex;
        switch (_chapter)
        {
            case Chapter.Chapter1:
                StartChapter1();
                break;

            case Chapter.Chapter2:
                StartChapter2();
                break;
        }
    }


    private void StartChapter1()
    {
        _chapter = Chapter.Chapter1;

        Vector3 spawnPos = GetSpawnPos();
        _grabGun.gameObject.SetActive(true);
        _grabGun.ResetGun();

        _dog.gameObject.SetActive(false);
        _cat.gameObject.SetActive(false);
        _grabObject.gameObject.SetActive(false);
        _fire.gameObject.SetActive(false);
        _man.gameObject.SetActive(false);
        _fireExtinguisher.gameObject.SetActive(false);
        _dog.transform.position = spawnPos;
        _cat.transform.position = spawnPos;
        _grabObject.transform.position = spawnPos + Vector3.up;
        _grabObject.Rigidbody.isKinematic = false;
        _grabObject.Rigidbody.useGravity = true;
        _grabObject.Rigidbody.velocity = Vector3.zero;
        _grabObject.transform.parent = null;
        _grabObject.SetGrabState(false);

        _dog.SetTargetGrabObject(null);
        _dog.ChangeState(AnimalState.Idle);
        _dog.gameObject.SetActive(true);
        _cat.gameObject.SetActive(true);
        _grabObject.gameObject.SetActive(true);
    }


    private void StartChapter2()
    {
        _fire.gameObject.SetActive(true);
        _man.gameObject.SetActive(true);
        _fireExtinguisher.gameObject.SetActive(true);
        _grabGun.gameObject.SetActive(false);
        _dog.gameObject.SetActive(false);
        _cat.gameObject.SetActive(false);
        _grabObject.gameObject.SetActive(false);
        _man.transform.position = GetFloorCenterPos();
        _fire.transform.position = SearchFirePos();
        _fire.SetFire();
        Vector3 dir = _fire.transform.position - _man.transform.position;
        dir.y = 0;

        if(dir.sqrMagnitude > 0.01f)
        {
            Quaternion targetRot = Quaternion.LookRotation(dir);
            _man.transform.rotation = Quaternion.Euler(0, targetRot.eulerAngles.y, 0);
        }
    }


    private Vector3 GetSpawnPos()
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


    private Vector3 GetFloorCenterPos()
    {
        if (_room == null)
            _room = FindAnyObjectByType<MRUKRoom>();


        var floorAnchor = _room.FloorAnchor;
        return _room.FloorAnchor.transform.position;
    }

    private Vector3 SearchFirePos()
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
                Vector3 center = anchorPosition;
                Vector3 direction = (center - randomCorner).normalized;
                float offset = Mathf.Min(_fire.Size.x, _fire.Size.z) / 2f;
                Vector3 insidePoint = randomCorner + direction * offset;

                return insidePoint;
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

        return GetSpawnPos();
    }


    public Vector3 SearchRandomFloorPos()
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

        return GetSpawnPos();
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

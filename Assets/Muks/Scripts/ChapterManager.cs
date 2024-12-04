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
    [SerializeField] private GameObject _man;
    [SerializeField] private GrabObject _grabObject;

    private Chapter _chapter;


   

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
        _dog.transform.position = spawnPos;
        //_cat.transform.position = spawnPos;
        _grabObject.transform.position = spawnPos + Vector3.up;
        _grabObject.Rigidbody.isKinematic = false;
        _grabObject.Rigidbody.useGravity = true;
        _grabObject.Rigidbody.velocity = Vector3.zero;
        _grabObject.transform.parent = null;
        _grabObject.SetGrabState(false);

        _dog.SetTargetGrabObject(null);
        _dog.ChangeState(AnimalState.Idle);
        _dog.gameObject.SetActive(true);
        _cat.gameObject.SetActive(false);
        _grabObject.gameObject.SetActive(true);
    }


    private void StartChapter2()
    {
        _fire.gameObject.SetActive(true);
        _man.gameObject.SetActive(true);
        _grabGun.gameObject.SetActive(false);
        _dog.gameObject.SetActive(false);
        _cat.gameObject.SetActive(false);
        _grabObject.gameObject.SetActive(false);

        _fire.transform.position = SearchFirePos();

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


    private Vector3 SearchFirePos()
    {
        MRUKRoom room = FindAnyObjectByType<MRUKRoom>();
        var floorAnchor = room.FloorAnchor;

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
}

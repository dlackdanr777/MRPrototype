using Meta.XR.MRUtilityKit;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum Chapter
{
    Chapter1,
    Chapter2,
    Chapter3
}



public class ChapterManager : MonoBehaviour
{
    [SerializeField] private FloorDetectManager _floorDetectManager;
    [SerializeField] private MRUK _mruk;
    [SerializeField] private Transform _spawnPos;
    [SerializeField] private GrabGun _grabGun;
    [SerializeField] private Dog _dog;
    [SerializeField] private GrabObject _grabObject;

    private Chapter _chapter;

    public void ResetChapter()
    {
        switch (_chapter)
        {
            case Chapter.Chapter1:
                StartDogChapter();
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
                StartDogChapter();
                break;

        }

    }


    private void StartDogChapter()
    {
        _chapter = Chapter.Chapter1;

        Vector3 spawnPos = GetSpawnPos();
        _grabGun.gameObject.SetActive(true);
        _grabGun.ResetGun();

        _dog.gameObject.SetActive(false);
        _grabObject.gameObject.SetActive(false);
        _dog.transform.position = spawnPos;
        _grabObject.transform.position = spawnPos + Vector3.up;
        _grabObject.Rigidbody.isKinematic = false;
        _grabObject.Rigidbody.useGravity = true;
        _grabObject.Rigidbody.velocity = Vector3.zero;
        _grabObject.transform.parent = null;
        _grabObject.SetGrabState(false);

        _dog.SetTargetGrabObject(null);
        _dog.ChangeState(AnimalState.Idle);
        _dog.gameObject.SetActive(true);
        _grabObject.gameObject.SetActive(true);

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
}

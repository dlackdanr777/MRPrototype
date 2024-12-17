using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;


public enum FootballPlayerType
{
    Red,
    Yellow,
    White,
    Black,
    Purple,
    Length
}


public class FootballPlayer : MonoBehaviour, IChapterObject
{

    [Header("Option")]
    [SerializeField] private FootballPlayerType _type;
    public FootballPlayerType Type => _type;


    [Space]
    [Header("Components")]
    [SerializeField] private NavMeshAgent _agent;


    [Header("Position Option")]
    [SerializeField] private bool _drawGizmos;
    [SerializeField] private Vector3 _size;
    [SerializeField] private Vector3 _center;

    private ChapterManager _chapterManager;


    public void Enabled(ChapterManager manager)
    {
        if (_chapterManager == null)
            _chapterManager = manager;

        ResetPos();
    }

    public void Disabled(ChapterManager manager)
    {
    }

    public void FixedUpdate()
    {
        ChangeTarget();
    }


    public void ChangeTarget()
    {
        if (!_agent.enabled || !_agent.isOnNavMesh)
            return;

        if (_agent.pathPending)
            return;

        if (_agent.remainingDistance <= _agent.stoppingDistance * 2f)
        {
            _agent.SetDestination(_chapterManager.GetRandomFloorPos());
        }
    }

    public void ResetPos()
    {
        _agent.enabled = false;
        SetPos();
        _agent.enabled = true;
        _agent.SetDestination(_chapterManager.GetRandomFloorPos());
    }


    private void SetPos()
    {
        if(_chapterManager == null)
        {
            Debug.Log("é�� �Ŵ����� ��ϵǾ����� �ʽ��ϴ�.");
            return;
        }

        bool isPositionValid = false;
        int cnt = 0;
        Vector3 floorCenter = _chapterManager.GetFloorCenterPos();

        while (!isPositionValid)
        {
            // ���ο� ��ġ ����
            transform.position = _chapterManager.GetRandomFloorPos();
            transform.rotation = Quaternion.Euler(0, Random.Range(0f, 360f), 0);

            // �ڽ� �߽� ��ġ ���
            Vector3 boxCenter = transform.position + _center;
            Quaternion boxRotation = transform.rotation;

            // �浹ü Ȯ�� (Floor �±� ����)
            Collider[] colliders = Physics.OverlapBox(boxCenter, _size / 2, boxRotation);
            isPositionValid = true;

            foreach (var collider in colliders)
            {
                if (collider.gameObject != gameObject && collider.gameObject.layer != LayerMask.NameToLayer("Floor"))
                {
                    isPositionValid = false;
                    break;
                }
            }

            if (10 <= cnt)
            {
                transform.position = floorCenter;
                return;
            }
            cnt++;
        }
    }


    private void OnDrawGizmos()
    {
        if (!_drawGizmos)
            return;

        Gizmos.color = Color.green;
        Vector3 boxCenter = transform.position + _center;
        Gizmos.DrawWireCube(boxCenter, _size);
    }


}

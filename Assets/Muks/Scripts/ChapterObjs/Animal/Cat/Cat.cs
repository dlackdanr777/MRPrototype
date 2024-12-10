using System;
using System.Collections;
using UnityEngine;
using UnityEngine.AI;

public class Cat : MonoBehaviour, IChapterObject
{
    public event Action<AnimalState> OnStateChangeHandler;
    public event Action<Collider> OnTriggerEnterHandler;
    public event Action<Collider> OnTriggerEixtHandler;

    [Header("Components")]
    [SerializeField] private Transform _headTarget;
    public Transform HeadTarget => _headTarget;

    [SerializeField] private NavMeshAgent _agent;
    [SerializeField] private ChapterManager _chapterManager;
    [SerializeField] private Animator _animator;
    public Animator Animator => _animator;

/*    [SerializeField] private HeadTracking _headTracking;
    public HeadTracking HeadTracking => _headTracking;*/

    [SerializeField] private float _speed;


    private Coroutine _searchPosCoroutine;
    private Vector3 _targetPos;
    private AnimalState _state;
    private CatStateMachine _stateMachine;


    public void Enabled(ChapterManager manager)
    {
        _agent.enabled = false;
        ChangeState(AnimalState.Idle);
        transform.position = manager.GetCameraSpawnPos();
        _targetPos = transform.position;
        _agent.enabled = true;
    }

    public void Disabled(ChapterManager manager)
    {
    }



    private void Start()
    {
        _stateMachine = new CatStateMachine(this);
        _targetPos = transform.position;
        ChangeState(AnimalState.Idle);
    }

    public void OnEnable()
    {
        if (_searchPosCoroutine != null)
            StopCoroutine(_searchPosCoroutine);

        _searchPosCoroutine = StartCoroutine(SearchRandomFloorPosRoutine());
    }


    private void Update()
    {
        _stateMachine.OnUpdate();
    }

    private void FixedUpdate()
    {
        _stateMachine.OnFixedUpdate();
    }


    public void ChangeState(AnimalState state)
    {
        if (_state == state)
            return;

        _state = state;
        _animator.SetInteger("State", (int)_state);
        OnStateChangeHandler?.Invoke(state);
    }

    public void Tracking()
    {
        if (!_agent.enabled)
            return;

        if (!_agent.isOnNavMesh)
            return;

        Debug.Log("�̵��� �����");
        // ���� �ӵ��� ��ǥ ���� ���
        Vector3 directionToTarget = (_targetPos - _agent.transform.position).normalized;
        Vector3 currentVelocity = _agent.velocity;

        // ���� �ӵ��� ��ǥ ����� �����ϸ� 1, �ݴ� �����̸� -1
        float forwardDot = Vector3.Dot(currentVelocity.normalized, directionToTarget);

        // �ӵ��� ũ�⸦ ������� ����ȭ
        float currentSpeedNormalized = Mathf.Clamp(currentVelocity.magnitude / _agent.speed, 0, 1);

        // ���⿡ ���� �� ��ȣ ����
        currentSpeedNormalized *= Mathf.Sign(forwardDot);

        // �ִϸ����Ϳ� �� ����
        _animator.SetFloat("Speed", currentSpeedNormalized);

        // ��ǥ ��ġ ����
        _agent.SetDestination(_targetPos);
    }

    public bool IsReachedDestination()
    {
        if (!_agent.enabled)
        {
            Debug.LogWarning("NavMeshAgent�� Ȱ��ȭ���� �ʾҽ��ϴ�.");
            return false;
        }

        // NavMesh ���� ������Ʈ�� �ִ��� Ȯ��
        if (!_agent.isOnNavMesh)
        {
            Debug.LogWarning("NavMeshAgent�� NavMesh ���� ��ġ���� �ʾҽ��ϴ�.");
            return false;
        }


        if (!_agent.pathPending && _agent.remainingDistance <= _agent.stoppingDistance && _agent.velocity.sqrMagnitude <= 0.005f)
        {
            return true; // ������ ����
        }

        return false; // ������ �̵���

    }

    public void SetNavmeshEnable(bool value)
    {
        _agent.enabled = value;

        if (!value)
            _animator.SetFloat("Speed", 0);
    }


    private IEnumerator SearchRandomFloorPosRoutine()
    {
        float interval = 20;
        while(true)
        {
            yield return new WaitForSeconds(interval * UnityEngine.Random.Range(0.1f, 1.5f));
            _targetPos = _chapterManager.GetRandomFloorPos();

            if(_agent.enabled )
                _agent.SetDestination(_targetPos);
        }
    }


    private void OnTriggerEnter(Collider other)
    {
        OnTriggerEnterHandler?.Invoke(other);
    }

    private void OnTriggerExit(Collider other)
    {
        OnTriggerEixtHandler?.Invoke(other);
    }
}




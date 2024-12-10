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

        Debug.Log("이동중 고양이");
        // 현재 속도와 목표 방향 계산
        Vector3 directionToTarget = (_targetPos - _agent.transform.position).normalized;
        Vector3 currentVelocity = _agent.velocity;

        // 현재 속도가 목표 방향과 동일하면 1, 반대 방향이면 -1
        float forwardDot = Vector3.Dot(currentVelocity.normalized, directionToTarget);

        // 속도의 크기를 기반으로 정규화
        float currentSpeedNormalized = Mathf.Clamp(currentVelocity.magnitude / _agent.speed, 0, 1);

        // 방향에 따라 값 부호 변경
        currentSpeedNormalized *= Mathf.Sign(forwardDot);

        // 애니메이터에 값 설정
        _animator.SetFloat("Speed", currentSpeedNormalized);

        // 목표 위치 설정
        _agent.SetDestination(_targetPos);
    }

    public bool IsReachedDestination()
    {
        if (!_agent.enabled)
        {
            Debug.LogWarning("NavMeshAgent가 활성화되지 않았습니다.");
            return false;
        }

        // NavMesh 위에 에이전트가 있는지 확인
        if (!_agent.isOnNavMesh)
        {
            Debug.LogWarning("NavMeshAgent가 NavMesh 위에 배치되지 않았습니다.");
            return false;
        }


        if (!_agent.pathPending && _agent.remainingDistance <= _agent.stoppingDistance && _agent.velocity.sqrMagnitude <= 0.005f)
        {
            return true; // 목적지 도착
        }

        return false; // 목적지 미도착

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




using System;
using UnityEngine;
using UnityEngine.AI;


public enum AnimalState
{
    Idle,
    Sit,
    Touch,
    TrackingObject,
    CollectObject,
    Length,
}


public class Dog : MonoBehaviour
{
    public event Action<AnimalState> OnStateChangeHandler;
    public event Action<Collider> OnTriggerEnterHandler;
    public event Action<Collider> OnTriggerEixtHandler;

    [Header("Components")]
    [SerializeField] private Transform _targetPlayer;
    public Transform TargetPlayer => _targetPlayer;

    [SerializeField] private HeadTracking _headTracking;
    public HeadTracking HeadTracking => _headTracking;

    [SerializeField] private Transform _mouthTr;
    [SerializeField] private NavMeshAgent _agent;
    [SerializeField] private Animator _animator;

    [Space]
    [Header("Settings")]
    [SerializeField] private AnimalState _state;
    [SerializeField] private float _rotateSpeed = 1;


    private GrabObject _targetGrabObj;
    public GrabObject TargetGrabObj => _targetGrabObj;
    private DogStateMachine _stateMachine;

    public bool NavmeshEnabled => _agent.enabled;


    private void Start()
    {
        _stateMachine = new DogStateMachine(this);
        ChangeState(AnimalState.Idle);
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

    public void SetTargetGrabObject(GrabObject grabObject)
    {
        _targetGrabObj = grabObject;
    }

    public void GrabObject(GrabObject target)
    {
        GrabObject[] grabObjects = _mouthTr.GetComponentsInChildren<GrabObject>(); 
        for(int i = 0, cnt = grabObjects.Length; i < cnt; ++i)
        {
            grabObjects[i].transform.parent = null;
            grabObjects[i].Rigidbody.isKinematic = false;
            grabObjects[i].Rigidbody.useGravity = true;
            grabObjects[i].SetGrabState(false);
        }

        if (target == null)
            return;

        target.transform.parent = _mouthTr;
        target.Rigidbody.isKinematic = true;
        target.Rigidbody.useGravity = false;
        target.transform.localPosition = Vector3.zero;
        target.SetGrabState(true);
    }


    public void Tracking(Transform target)
    {
        _agent.enabled = true;
        if (target == null)
            return;

        if (!_agent.isOnNavMesh)
            return;

        // 타겟과 현재 위치의 방향 계산 (XZ 평면)
        Vector3 targetDirection = target.position - transform.position;
        targetDirection.y = 0; // Y축 제외
        targetDirection.Normalize(); // 정규화

        // 현재 오브젝트의 XZ 평면 forward 방향 계산
        Vector3 currentForward = transform.forward;
        currentForward.y = 0; // Y축 제외
        currentForward.Normalize(); // 정규화

        // 현재 방향과 타겟 방향 간의 각도 계산
        float angle = Vector3.Angle(currentForward, targetDirection);

        // 각도에 따라 회전 속도를 가중치로 계산 (임계값: 30도)
        float speedFactor = Mathf.Clamp01(angle / 30f); // 각도가 작을수록 속도가 감소

        // 각도가 임계값보다 크면 회전
        if (angle > 10f) // 1도 이하일 때는 정지
        {
            // 목표 회전 (XZ 평면 기준)
            Quaternion targetRotation = Quaternion.LookRotation(targetDirection);

            // Y축 회전만 적용
            Quaternion smoothedRotation = Quaternion.Slerp(transform.rotation, targetRotation, _rotateSpeed * speedFactor * Time.deltaTime);
            transform.rotation = Quaternion.Euler(0, smoothedRotation.eulerAngles.y, 0); // Y축 회전만 적용
        }


        float currentSpeedNormalized = Mathf.Clamp(_agent.velocity.magnitude / _agent.speed, 0, 1);
        _animator.SetFloat("Speed", currentSpeedNormalized);
        _agent.SetDestination(target.position);
    }


    public void SetNavmeshEnable(bool value)
    {
        _agent.enabled = value;

        if (!value)
            _animator.SetFloat("Speed", 0);
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

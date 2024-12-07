using UnityEngine;
using UnityEngine.AI;

public class NewBehaviourScript : MonoBehaviour
{
    [Header("Components")]
    [SerializeField] private NavMeshAgent _agent;
    [SerializeField] private Rigidbody _rigidBody;
    [SerializeField] private Transform _headTr;


    [SerializeField] private float _speed;
    [SerializeField] private float _rotateSpeed;


    private int _lastDirection = 0; // -1: 왼쪽, 1: 오른쪽, 0: 초기값

    private void Update()
    {
        MoveFoward();
    }

    public void MoveFoward()
    {
        Vector3 targetPosition = _rigidBody.position + transform.forward * _speed * Time.deltaTime;
        _rigidBody.MovePosition(targetPosition);
        CheckForObstacles();
    }

    public void MoveBackward()
    {
        Vector3 targetPosition = _rigidBody.position - transform.forward * _speed * Time.deltaTime * 2;
        _rigidBody.MovePosition(targetPosition);
    }

    public void Rotate(float angle)
    {
        Quaternion targetRotation = Quaternion.Euler(0, angle, 0) * transform.rotation;
        transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, _rotateSpeed * Time.deltaTime);
    }


    private void CheckForObstacles()
    {
        float boxDistance = 1f; // BoxCast 길이
        Vector3 boxSize = new Vector3(0.2f, 0.1f, 0.4f); // BoxCast 크기 (반지름)

        // 방향 정의
        Vector3 forward = transform.forward;
        Vector3 left = -transform.right;
        Vector3 right = transform.right;

        // BoxCast 발사
        bool isFrontBlocked = Physics.BoxCast(_headTr.position, boxSize, forward, Quaternion.identity, boxDistance);
        bool isLeftBlocked = Physics.BoxCast(_headTr.position, boxSize, left, Quaternion.identity, boxDistance);
        bool isRightBlocked = Physics.BoxCast(_headTr.position, boxSize, right, Quaternion.identity, boxDistance);

        // 시각적 디버그
        Debug.DrawRay(_headTr.position, forward * boxDistance, isFrontBlocked ? Color.red : Color.green);
        Debug.DrawRay(_headTr.position, left * boxDistance, isLeftBlocked ? Color.red : Color.green);
        Debug.DrawRay(_headTr.position, right * boxDistance, isRightBlocked ? Color.red : Color.green);

        // 행동 결정
        if (isFrontBlocked)
        {
            if(!isLeftBlocked && !isRightBlocked)
            {
                // 전방 막힘 & 양옆 모두 비어 있는 경우
                if (_lastDirection == 0) // 초기 상태일 경우 랜덤으로 방향 설정
                {
                    _lastDirection = Random.Range(0, 2) == 0 ? -1 : 1;
                }

                // 마지막 방향으로 계속 회전
                Rotate(_lastDirection == -1 ? -90 : 90);
            }

            else if (!isLeftBlocked)
            {
                _lastDirection = -1; // 방향 저장
                Rotate(-90f);
            }
            else if (!isRightBlocked)
            {
                _lastDirection = 1; // 방향 저장
                Rotate(90f);
            }
            else if (isLeftBlocked && isRightBlocked)
            {
                _lastDirection = 1;
                Rotate(180f);
            }
        }
    }




}




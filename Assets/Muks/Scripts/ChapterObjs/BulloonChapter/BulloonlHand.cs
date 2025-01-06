using System;
using UnityEngine;

public class BalloonHand : MonoBehaviour, IChapterObject
{
    public event Action<BalloonObject, Vector3> OnTriggerEnterHandler;

    private Vector3 _previousHandPosition; // 이전 프레임의 손 위치
    private Vector3 _currentHandVelocity;  // 손의 속도

    public void Enabled(ChapterManager manager)
    {
    }

    public void Disabled(ChapterManager manager)
    {
    }


    public void RemoveAllTriggerEnterEvent()
    {
        OnTriggerEnterHandler = null;
    }

    private void Update()
    {
        Vector3 currentHandPosition = transform.position;
        _currentHandVelocity = (currentHandPosition - _previousHandPosition) / Time.deltaTime;
        _previousHandPosition = currentHandPosition;
    }


    private void OnCollisionEnter(Collision collision)
    {
        if (!collision.gameObject.TryGetComponent(out BalloonObject bulloonObject))
            return;

        float pushForce = CalculatePushForce(_currentHandVelocity);
        Vector3 pushDir = (collision.contacts[0].point - transform.position).normalized * pushForce;
        OnTriggerEnterHandler?.Invoke(bulloonObject, pushDir);
    }

    private float CalculatePushForce(Vector3 handVelocity)
    {
        // 손 속도의 크기(Magnitude)를 푸쉬 파워로 변환
        float basePushForce = 0.1f;   // 기본 푸쉬 파워 (최소값)
        float maxPushForce = 10f;  // 최대 푸쉬 파워
        float velocityMagnitude = handVelocity.magnitude; // 손 속도의 크기

        // 손 속도를 기반으로 푸쉬 파워 계산 (최소-최대 값 제한)
        return Mathf.Clamp(basePushForce + velocityMagnitude, basePushForce, maxPushForce);
    }
}

using System;
using UnityEngine;

public class BalloonHand : MonoBehaviour, IChapterObject
{
    public event Action<BalloonObject, Vector3> OnTriggerEnterHandler;

    private Vector3 _previousHandPosition; // ���� �������� �� ��ġ
    private Vector3 _currentHandVelocity;  // ���� �ӵ�

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
        // �� �ӵ��� ũ��(Magnitude)�� Ǫ�� �Ŀ��� ��ȯ
        float basePushForce = 0.1f;   // �⺻ Ǫ�� �Ŀ� (�ּҰ�)
        float maxPushForce = 10f;  // �ִ� Ǫ�� �Ŀ�
        float velocityMagnitude = handVelocity.magnitude; // �� �ӵ��� ũ��

        // �� �ӵ��� ������� Ǫ�� �Ŀ� ��� (�ּ�-�ִ� �� ����)
        return Mathf.Clamp(basePushForce + velocityMagnitude, basePushForce, maxPushForce);
    }
}

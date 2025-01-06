using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BalloonObject : MonoBehaviour, IChapterObject
{
    [SerializeField] private Rigidbody rb;
    public Rigidbody RigidBody => rb;
    [SerializeField] private CapsuleCollider capsuleCollider;

    [SerializeField] private float airDensity = 1.225f;  // ���� �е� (kg/m��)
    [SerializeField] private float gravity = 9.81f;      // �߷� ���ӵ� (m/s��)
    [SerializeField] private float balloonMass = 0.1f;   // ǳ���� ���� (kg)
    [SerializeField] private float drag = 2f;            // ���� ���� ���

    private float balloonVolume;


    [Header("Option")]
    [SerializeField] private GameColorType _type;
    public GameColorType Type => _type;

    private ChapterManager _chapterManager;


    private void Awake()
    {
        if (rb == null || capsuleCollider == null)
        {
            Debug.LogError("Rigidbody�� CapsuleCollider�� �������� �ʾҽ��ϴ�!");
            return;
        }

        rb.useGravity = false; // �߷��� ������� ����
        rb.drag = drag;        // ���� ���� ����

        CalculateBalloonVolume();
    }

    private void FixedUpdate()
    {
        if (rb == null) return;

        // �η� ���
        float buoyantForce = airDensity * balloonVolume * gravity;

        // �߷����� ���� �ϰ� �� ���
        float gravityForce = balloonMass * gravity;

        // �� �� = �η� - �߷�
        float netForce = buoyantForce - gravityForce;

        // ���� ����ϴ� �� ����
        rb.AddForce(Vector3.up * netForce, ForceMode.Force);

        // ���� ��鸲 �߰� (�ڿ������� ������)
        float floatOffset = Mathf.Sin(Time.time) * 0.5f;
        rb.AddForce(Vector3.up * floatOffset, ForceMode.Force);
    }

    private void CalculateBalloonVolume()
    {
        if (capsuleCollider == null) return;

        float radius = capsuleCollider.radius;
        float height = capsuleCollider.height;

        // ĸ�� ���� ���
        float cylinderHeight = height - 2 * radius; // ���� �κ� ����
        float sphereVolume = (4f / 3f) * Mathf.PI * Mathf.Pow(radius, 3); // ��ü ����
        float cylinderVolume = Mathf.PI * Mathf.Pow(radius, 2) * cylinderHeight; // ����� ����

        balloonVolume = sphereVolume + cylinderVolume;

        Debug.Log($"ǳ���� ����: {balloonVolume} m��");
    }


    public void Enabled(ChapterManager manager)
    {
        if (_chapterManager == null)
            _chapterManager = manager;

        ResetPos();
    }

    public void Disabled(ChapterManager manager)
    {
    }

    public void ResetPos()
    {
        transform.position = _chapterManager.GetRandomFloorPos() + Vector3.up * 1.5f;
        Quaternion randomRotation = Quaternion.Euler(
            Random.Range(0f, 360f), // X�� ȸ��
            Random.Range(0f, 360f), // Y�� ȸ��
            Random.Range(0f, 360f)  // Z�� ȸ��
        );
        transform.rotation = randomRotation;
    }


    private void OnCollisionEnter(Collision collision)
    {
        if (!collision.gameObject.CompareTag("Floor"))
            return;

        ResetPos();
    }
}

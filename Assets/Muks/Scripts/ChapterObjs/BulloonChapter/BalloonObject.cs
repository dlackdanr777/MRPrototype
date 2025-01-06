using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BalloonObject : MonoBehaviour, IChapterObject
{
    [SerializeField] private Rigidbody rb;
    public Rigidbody RigidBody => rb;
    [SerializeField] private CapsuleCollider capsuleCollider;

    [SerializeField] private float airDensity = 1.225f;  // 공기 밀도 (kg/m³)
    [SerializeField] private float gravity = 9.81f;      // 중력 가속도 (m/s²)
    [SerializeField] private float balloonMass = 0.1f;   // 풍선의 질량 (kg)
    [SerializeField] private float drag = 2f;            // 공기 저항 계수

    private float balloonVolume;


    [Header("Option")]
    [SerializeField] private GameColorType _type;
    public GameColorType Type => _type;

    private ChapterManager _chapterManager;


    private void Awake()
    {
        if (rb == null || capsuleCollider == null)
        {
            Debug.LogError("Rigidbody와 CapsuleCollider가 설정되지 않았습니다!");
            return;
        }

        rb.useGravity = false; // 중력을 사용하지 않음
        rb.drag = drag;        // 공기 저항 설정

        CalculateBalloonVolume();
    }

    private void FixedUpdate()
    {
        if (rb == null) return;

        // 부력 계산
        float buoyantForce = airDensity * balloonVolume * gravity;

        // 중력으로 인한 하강 힘 계산
        float gravityForce = balloonMass * gravity;

        // 총 힘 = 부력 - 중력
        float netForce = buoyantForce - gravityForce;

        // 위로 상승하는 힘 적용
        rb.AddForce(Vector3.up * netForce, ForceMode.Force);

        // 상하 흔들림 추가 (자연스러운 움직임)
        float floatOffset = Mathf.Sin(Time.time) * 0.5f;
        rb.AddForce(Vector3.up * floatOffset, ForceMode.Force);
    }

    private void CalculateBalloonVolume()
    {
        if (capsuleCollider == null) return;

        float radius = capsuleCollider.radius;
        float height = capsuleCollider.height;

        // 캡슐 부피 계산
        float cylinderHeight = height - 2 * radius; // 직선 부분 높이
        float sphereVolume = (4f / 3f) * Mathf.PI * Mathf.Pow(radius, 3); // 구체 부피
        float cylinderVolume = Mathf.PI * Mathf.Pow(radius, 2) * cylinderHeight; // 원기둥 부피

        balloonVolume = sphereVolume + cylinderVolume;

        Debug.Log($"풍선의 부피: {balloonVolume} m³");
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
            Random.Range(0f, 360f), // X축 회전
            Random.Range(0f, 360f), // Y축 회전
            Random.Range(0f, 360f)  // Z축 회전
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

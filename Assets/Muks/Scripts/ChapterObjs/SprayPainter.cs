using UnityEngine;
using UnityEngine.XR;

public class SprayPainter : MonoBehaviour, IChapterObject
{
    [Header("Components")]
    [SerializeField] private Transform _sprayStartTr; // 레이를 쏠 기준 Transform
    [SerializeField] private ParticleSystem _sprayParticle;
    [SerializeField] private AudioSource _audio;
    [SerializeField] private Animator _animator;
    [SerializeField] private Material _baseMaterial; // 기본 머티리얼 (원본)

    [Space]
    [Header("Options")]
    [SerializeField] private LayerMask _layerMask;
    [SerializeField] private float _maxDistance = 10f; // Raycast 최대 거리
    [SerializeField] private Color _sprayColor = Color.red; // 스프레이 색상
    [SerializeField] private float _brushSize = 0.1f; // 브러시 크기

    private Material _instanceMaterial; // 인스턴스화된 머티리얼
    private bool _wasTriggerPressed;


    private void Awake()
    {
        // 기본 머티리얼을 복제하여 인스턴스화
        if (_baseMaterial != null)
        {
            _instanceMaterial = new Material(_baseMaterial);
        }

        // 초기 색상 설정
        ChangePaintColor(_sprayColor);
    }

    public void Disabled(ChapterManager manager)
    {
        _sprayParticle.Stop();
        _audio.Stop();
        //_animator.SetBool("Press", false);
        _wasTriggerPressed = false;
    }

    public void Enabled(ChapterManager manager)
    {
        _sprayParticle.Stop();
        _audio.Stop();
        //_animator.SetBool("Press", false);
        _wasTriggerPressed = false;

        // 활성화 시 색상을 재설정
        ChangePaintColor(_sprayColor);
    }

    public void ChangePaintColor(Color newColor)
    {
        _sprayColor = newColor;

        // 새로 생성된 머티리얼의 색상 변경
        if (_instanceMaterial != null)
        {
            _instanceMaterial.color = newColor;
        }

        // 파티클 시스템의 Color over Lifetime 설정
        var colorOverLifetime = _sprayParticle.colorOverLifetime;
        colorOverLifetime.enabled = true;

        Gradient gradient = new Gradient();
        gradient.SetKeys(
            // 색상은 일정하게 유지
            new GradientColorKey[] {
                new GradientColorKey(newColor, 0.0f),
                new GradientColorKey(newColor, 1.0f)
            },
            // 알파값: 처음 0, 중간 1, 끝 0
            new GradientAlphaKey[] {
                new GradientAlphaKey(0.7f, 0.0f),
                new GradientAlphaKey(1.0f, 0.4f),
                new GradientAlphaKey(0.0f, 1.0f)
            }
        );

        colorOverLifetime.color = new ParticleSystem.MinMaxGradient(gradient);
    }

    private void FixedUpdate()
    {
        bool isTriggerPressed = IsTriggerPressed();

        if (isTriggerPressed)
        {
            Ray ray = new Ray(_sprayStartTr.position, _sprayStartTr.forward);
            StartPainting(ray);
        }

        if (isTriggerPressed && !_wasTriggerPressed)
        {
            _sprayParticle.Play();
            _audio.Play();
            //_animator.SetBool("Press", true);
        }
        else if (!isTriggerPressed && _wasTriggerPressed)
        {
            _sprayParticle.Stop();
            _audio.Stop();
            //_animator.SetBool("Press", false);
        }

        _wasTriggerPressed = isTriggerPressed;
    }

    private void StartPainting(Ray ray)
    {
        if (!Physics.Raycast(ray, out RaycastHit hit, _maxDistance, _layerMask))
            return;

        // PaintableObject 컴포넌트를 가진 오브젝트를 감지
        PaintableObject paintable = hit.collider.GetComponent<PaintableObject>();
        if (paintable != null)
        {
            // 충돌 지점의 UV 좌표 계산
            Vector2 uvCoord = hit.textureCoord;
            Debug.Log(uvCoord);
            // 페인팅 적용 (새로 생성된 머티리얼 사용)
            paintable.ApplyPaint(uvCoord, _instanceMaterial, _sprayColor, _brushSize);
        }
    }

    private bool IsTriggerPressed()
    {
        InputDevice rightHand = InputDevices.GetDeviceAtXRNode(XRNode.RightHand);
        if (rightHand.TryGetFeatureValue(CommonUsages.triggerButton, out bool isPressed))
            return isPressed;

        return false;
    }
}

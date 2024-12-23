using UnityEngine;
using UnityEngine.XR;

public class SprayPainter : MonoBehaviour, IChapterObject
{
    [Header("Components")]
    [SerializeField] private Transform _sprayStartTr; // ���̸� �� ���� Transform
    [SerializeField] private ParticleSystem _sprayParticle;
    [SerializeField] private AudioSource _audio;
    [SerializeField] private Animator _animator;
    [SerializeField] private Material _baseMaterial; // �⺻ ��Ƽ���� (����)

    [Space]
    [Header("Options")]
    [SerializeField] private LayerMask _layerMask;
    [SerializeField] private float _maxDistance = 10f; // Raycast �ִ� �Ÿ�
    [SerializeField] private Color _sprayColor = Color.red; // �������� ����
    [SerializeField] private float _brushSize = 0.1f; // �귯�� ũ��

    private Material _instanceMaterial; // �ν��Ͻ�ȭ�� ��Ƽ����
    private bool _wasTriggerPressed;


    private void Awake()
    {
        // �⺻ ��Ƽ������ �����Ͽ� �ν��Ͻ�ȭ
        if (_baseMaterial != null)
        {
            _instanceMaterial = new Material(_baseMaterial);
        }

        // �ʱ� ���� ����
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

        // Ȱ��ȭ �� ������ �缳��
        ChangePaintColor(_sprayColor);
    }

    public void ChangePaintColor(Color newColor)
    {
        _sprayColor = newColor;

        // ���� ������ ��Ƽ������ ���� ����
        if (_instanceMaterial != null)
        {
            _instanceMaterial.color = newColor;
        }

        // ��ƼŬ �ý����� Color over Lifetime ����
        var colorOverLifetime = _sprayParticle.colorOverLifetime;
        colorOverLifetime.enabled = true;

        Gradient gradient = new Gradient();
        gradient.SetKeys(
            // ������ �����ϰ� ����
            new GradientColorKey[] {
                new GradientColorKey(newColor, 0.0f),
                new GradientColorKey(newColor, 1.0f)
            },
            // ���İ�: ó�� 0, �߰� 1, �� 0
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

        // PaintableObject ������Ʈ�� ���� ������Ʈ�� ����
        PaintableObject paintable = hit.collider.GetComponent<PaintableObject>();
        if (paintable != null)
        {
            // �浹 ������ UV ��ǥ ���
            Vector2 uvCoord = hit.textureCoord;
            Debug.Log(uvCoord);
            // ������ ���� (���� ������ ��Ƽ���� ���)
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

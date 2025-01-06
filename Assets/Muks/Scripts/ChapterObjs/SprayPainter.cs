using TMPro;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR;

public class SprayPainter : MonoBehaviour, IChapterObject
{
    [Header("Components")]
    [SerializeField] private Transform _cursor;
    [SerializeField] private Transform _sprayStartTr; // ���̸� �� ���� Transform
    [SerializeField] private ParticleSystem _sprayParticle;
    [SerializeField] private AudioSource _audio;
    [SerializeField] private Animator _animator;
    [SerializeField] private Material _baseMaterial; // �⺻ ��Ƽ���� (����)


    [Space]
    [Header("UI")]
    [SerializeField] private Image _colorImage;
   
    [SerializeField] private TextMeshProUGUI _sizeText;

    [Space]
    [Header("Options")]
    [SerializeField] private LayerMask _layerMask;
    [SerializeField] private float _maxDistance = 10f; // Raycast �ִ� �Ÿ�
    [SerializeField] private Color _sprayColor = Color.red; // �������� ����
    [SerializeField] private float _brushSize = 0.1f; // �귯�� ũ��
    [SerializeField] private float _minBrushSize = 0.05f;
    [SerializeField] private float _maxBrushSize = 1f;

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
        _sizeText.SetText(Mathf.FloorToInt(_brushSize * 100).ToString());
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
    }


    public void ChangeBrushSize(float addValue)
    {
        _brushSize = Mathf.Clamp(_brushSize + addValue, _minBrushSize, _maxBrushSize);
        _sizeText.SetText(Mathf.FloorToInt(_brushSize * 100).ToString());
    }


    public void ChangePaintColor(Color newColor)
    {
        _sprayColor = newColor;
        _colorImage.color = newColor;

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

        Ray ray = new Ray(_sprayStartTr.position, _sprayStartTr.forward);
        UpdateCursor(ray);

        if (isTriggerPressed)
        {

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


    private void UpdateCursor(Ray ray)
    {
        if (Physics.Raycast(ray, out RaycastHit hit, _maxDistance, _layerMask))
        {
            // �浹�� ��ġ���� ���� �������� 0.01��ŭ �̵�
            Vector3 directionToPull = (ray.origin - hit.point).normalized; // ������ ���������� Ÿ�ٱ����� ����
            _cursor.transform.position = hit.point + directionToPull * 0.02f; // Ÿ�� ��ġ���� 0.01��ŭ �̵�
            return;
        }
        _cursor.transform.position = ray.origin + ray.direction.normalized * _maxDistance;
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

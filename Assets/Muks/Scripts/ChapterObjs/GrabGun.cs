using System;
using UnityEngine;
using UnityEngine.XR;

public class GrabGun : MonoBehaviour, IChapterObject
{
    public static event Action<GrabObject> OnShootObjectHandler;
    public static event Action<GrabObject> OnRecoveringObjectHandler;

    [Header("Components")]
    [SerializeField] private Transform _ballGrabTr;
    [SerializeField] private GameObject _effect;


    [Space]
    [Header("Settings")]
    [SerializeField] private float _cooldownTime = 0.5f; // �߻� �� ��ٿ� �ð�
    [SerializeField] private float _maxDistance = 100;
    [SerializeField] private float _returnSpeed = 10f;
    [SerializeField] private float _throwForce = 15f;
    [SerializeField] private LayerMask _interactableLayer;

    [Space]
    [Header("Audios")]
    [SerializeField] private AudioSource _onTriggerSource;
    [SerializeField] private AudioSource _audioSource;
    [SerializeField] private AudioClip _shootSound;
    [SerializeField] private AudioClip _grapSound;

    [SerializeField] private GrabObject _targetGrabObject;
    [SerializeField] private bool _isHold = false;

    private bool _wasTriggerPressed;
    private float _lastThrowTime = -Mathf.Infinity; // ������ �߻� �ð�


    public void Enabled(ChapterManager manager)
    {
        _effect.gameObject.SetActive(false);
        _onTriggerSource.Stop();
        _wasTriggerPressed = false;
        _lastThrowTime = -Mathf.Infinity;
        _isHold = false;
        _targetGrabObject = null;
    }

    public void Disabled(ChapterManager manager)
    {
        _isHold = false;
        _targetGrabObject = null;
    }

    private void Start()
    {
        _effect.gameObject.SetActive(false);
        _onTriggerSource.Stop();
    }


    private void Update()
    {
        bool isTriggerPressed = IsTriggerPressed();

        // Trigger ��ư ���� ó��
        if (isTriggerPressed)
        {
            if (!_isHold && Time.time - _lastThrowTime > _cooldownTime)
            {
                if (!_effect.activeSelf)
                    _effect.gameObject.SetActive(true);

                if (!_onTriggerSource.isPlaying)
                    _onTriggerSource.Play();

                CheckForObject();
                CollectObject(); // ������Ʈ�� _ballGrabTr ������ �̵�
            }
            else
            {
                if (_effect.activeSelf)
                    _effect.gameObject.SetActive(false);

                if (_onTriggerSource.isPlaying)
                    _onTriggerSource.Stop();
            }
        }

        // Trigger ���� ���� ó��
        if ((isTriggerPressed && !_wasTriggerPressed) && _isHold)
        {
            ThrowObject(); // ������ ����
        }

        // Trigger ���� ó��
        else if (!isTriggerPressed && _wasTriggerPressed)
        {
            if (!_isHold && _targetGrabObject != null)
            {
                _targetGrabObject.SetGrabState(false);
                _targetGrabObject.Rigidbody.isKinematic = false;
                _targetGrabObject.Rigidbody.useGravity = true;
                _targetGrabObject = null;
            }

            if (_effect.activeSelf)
                _effect.gameObject.SetActive(false);

            if (_onTriggerSource.isPlaying)
                _onTriggerSource.Stop();
        }

        _wasTriggerPressed = isTriggerPressed; // ���� Trigger ���¸� ����
    }


    private void CheckForObject()
    {
        if (_isHold && _targetGrabObject != null)
            return;

        Vector3 origin = _ballGrabTr.position;
        Vector3 halfExtents = new Vector3(0.3f, 0.3f, 0.3f);
        Vector3 dir = _ballGrabTr.forward;
        RaycastHit hit;

        if (Physics.BoxCast(origin, halfExtents, dir, out hit, Quaternion.identity, _maxDistance, _interactableLayer))
        {
            if (hit.collider.TryGetComponent(out GrabObject grabObj))
            {
                if (grabObj.IsGrab)
                    return;

                grabObj.SetGrabState(true);
                _targetGrabObject = grabObj;
                OnRecoveringObjectHandler?.Invoke(grabObj);
            }
        }
    }


    private void CollectObject()
    {
        if (_targetGrabObject == null || _isHold)
            return;

        Vector3 targetPosition = _ballGrabTr.position;
        float distance = Vector3.Distance(_targetGrabObject.transform.position, targetPosition);
        float speed = Mathf.Clamp(distance * _returnSpeed, _returnSpeed * 0.5f, _returnSpeed * 1.5f);

        _targetGrabObject.transform.position = Vector3.MoveTowards(
            _targetGrabObject.transform.position,
            targetPosition,
            speed * Time.deltaTime
        );

        _targetGrabObject.Rigidbody.isKinematic = true;
        _targetGrabObject.Rigidbody.useGravity = false;

        if (distance < 0.05f)
        {
            _targetGrabObject.transform.position = targetPosition;
            RetrieveObject();
        }
    }

    private void RetrieveObject()
    {
        if (_targetGrabObject == null)
            return;

        _isHold = true;
        _targetGrabObject.Rigidbody.isKinematic = true;
        _targetGrabObject.transform.SetParent(transform);
        _targetGrabObject.transform.position = _ballGrabTr.position;

        _audioSource.PlayOneShot(_grapSound);
    }

    private void ThrowObject()
    {
        if (_targetGrabObject == null)
            return;

        _isHold = false;
        _targetGrabObject.transform.SetParent(null);
        _targetGrabObject.Rigidbody.isKinematic = false;
        _targetGrabObject.Rigidbody.AddForce(transform.forward * _throwForce, ForceMode.Impulse);
        _audioSource.PlayOneShot(_shootSound);
        _lastThrowTime = Time.time; // �߻� �ð� ����
        OnShootObjectHandler?.Invoke(_targetGrabObject);
    }


    private bool IsTriggerPressed()
    {
        InputDevice rightHand = InputDevices.GetDeviceAtXRNode(XRNode.RightHand);
        if (rightHand.TryGetFeatureValue(CommonUsages.triggerButton, out bool isPressed))
            return isPressed;

        return false;
    }
}

using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.XR;

public class UiAlphabet : MonoBehaviour
{
    [SerializeField] private Transform _player;
    [SerializeField] private ChapterManager _chapterManager;
    [SerializeField] private AudioController _audioController;
    [SerializeField] private AudioClip _buttonSound;
    [SerializeField] private AudioClip _uiSound;

    [SerializeField] private RectTransform _slotParent;
    [SerializeField] private UIAlphabetSlot _slotPrefab;


    public OVRRayHelper RayHelper;
    public OVRInputModule InputModule;
    public OVRRaycaster Raycaster;
    public OVRGazePointer GazePointer;
    public OVRCameraRig _cameraRig;

    private List<UIAlphabetSlot> _slotList;
    private OVRControllerHelper _rightControllerHelper;
    private OVRControllerHelper _leftControllerHelper;

    private int _currentIndex;
    private bool _yButtonPressed = false;
    private bool _joystickLeftMoved= false;
    private bool _joystickRightMoved = false;

    private void Awake()
    {
        _slotList = new List<UIAlphabetSlot>();

        for(int i = 0, cnt = _chapterManager.ChapterLength; i < cnt; i++)
        {
            char alphabet = (char)('A' + i);
            int index = i;
            UIAlphabetSlot slot = Instantiate(_slotPrefab, _slotParent);
            slot.Init(() => OnButtonClicked(index));
            slot.SetText(alphabet.ToString());
            slot.SetOutline(false);
            _slotList.Add(slot);
        }

        SetupInteractionDependencies();
        Hide();
    }


    private void Update()
    {
        ButtonControll();
        //JoystickControll();
    }


    public void Show()
    {
        if (_slotParent.gameObject.activeSelf)
            return;

        _slotParent.gameObject.SetActive(true);
        _leftControllerHelper.RayHelper.Renderer.enabled = true;
        _rightControllerHelper.RayHelper.Renderer.enabled = true;
        Vector3 playerPosition = _player.transform.position;
        Vector3 forwardDirection = _player.transform.forward;
        Vector3 targetPosition = new Vector3(playerPosition.x + forwardDirection.x * 2.5f, _player.transform.position.y, playerPosition.z + forwardDirection.z * 2.5f);
        transform.position = targetPosition;

        Vector3 dir = (transform.position - _player.transform.position).normalized;
        float angle = Mathf.Atan2(dir.x, dir.z) * Mathf.Rad2Deg;
        transform.rotation = Quaternion.Euler(0, angle, 0);

        _currentIndex = _chapterManager.CurrentChapter;
        SetOutline();
    }

    public void Hide()
    {
        if (!_slotParent.gameObject.activeSelf)
            return;

        _leftControllerHelper.RayHelper.Renderer.enabled = false;
        _rightControllerHelper.RayHelper.Renderer.enabled = false;
        _slotParent.gameObject.SetActive(false);
    }


    private void ButtonControll()
    {
        bool yButtonPressed = IsLeftYButtonPressed();
        if (yButtonPressed && !_yButtonPressed)
        {
            _audioController.PlayOneShot(_uiSound);
            if (!_slotParent.gameObject.activeSelf)
            {
                Show();
            }

            else
            {
                Hide();
            }
        }
        _yButtonPressed = yButtonPressed;
    }


    private void JoystickControll()
    {
        bool joystickLeftMoved = IsJoystickLeftMoved();
        bool joystickRightMoved = IsJoystickRightMoved();

        if (joystickLeftMoved && !_joystickLeftMoved)
        {
            ChangeIndex(-1);
        }

        else if (joystickRightMoved && !_joystickRightMoved)
        {
            ChangeIndex(1);
        }

        _joystickLeftMoved = joystickLeftMoved;
        _joystickRightMoved = joystickRightMoved;
    }


    private void ChangeIndex(int dir)
    {
        if (!_slotParent.gameObject.activeSelf)
            return;

        if (dir == 0)
            return;

        dir = Mathf.Clamp(dir, -1, 1);
        _currentIndex = (_currentIndex + dir) % _chapterManager.ChapterLength;
        _currentIndex = _currentIndex < 0 ? _currentIndex + _chapterManager.ChapterLength : _currentIndex;
        SetOutline();
    }

    private void SetOutline()
    {
        for (int i = 0, cnt = _slotList.Count; i < cnt; i++)
        {
            _slotList[i].SetOutline(false);
        }

        _slotList[_currentIndex].SetOutline(true);
    }

    private bool IsLeftXButtonPressed()
    {
        InputDevice rightHand = InputDevices.GetDeviceAtXRNode(XRNode.LeftHand);
        if (rightHand.TryGetFeatureValue(CommonUsages.primaryButton, out bool isPressed))
            return isPressed;

        return false;
    }

    private bool IsLeftYButtonPressed()
    {
        InputDevice rightHand = InputDevices.GetDeviceAtXRNode(XRNode.LeftHand);
        if (rightHand.TryGetFeatureValue(CommonUsages.secondaryButton, out bool isPressed))
            return isPressed;

        return false;
    }

    private bool IsJoystickLeftMoved()
    {
        // 왼쪽 컨트롤러 장치 가져오기
        InputDevice hand = InputDevices.GetDeviceAtXRNode(XRNode.LeftHand);

        // 조이스틱 값 읽기
        if (hand.TryGetFeatureValue(CommonUsages.primary2DAxis, out Vector2 joystickPosition))
        {
            // 조이스틱이 왼쪽으로 움직였는지 확인 (-X 방향)
            if (joystickPosition.x < -0.5f) // -0.5f는 움직임 민감도를 나타냄 (조정 가능)
            {
                return true;
            }
        }

        return false;
    }

    private bool IsJoystickRightMoved()
    {
        // 왼쪽 컨트롤러 장치 가져오기
        InputDevice hand = InputDevices.GetDeviceAtXRNode(XRNode.LeftHand);

        // 조이스틱 값 읽기
        if (hand.TryGetFeatureValue(CommonUsages.primary2DAxis, out Vector2 joystickPosition))
        {
            if (0.5f < joystickPosition.x)
            {
                return true;
            }
        }

        return false;
    }


    private void SetupInteractionDependencies()
    {
        if (!_cameraRig)
            return;

        GazePointer.rayTransform = _cameraRig.centerEyeAnchor;
        InputModule.rayTransform = _cameraRig.rightControllerAnchor;
        Raycaster.pointer = _cameraRig.rightControllerAnchor.gameObject;

        if (_cameraRig.GetComponentsInChildren<OVRRayHelper>(false).Length > 0)
            return;

        _rightControllerHelper = _cameraRig.rightControllerAnchor.GetComponentInChildren<OVRControllerHelper>();
        if (_rightControllerHelper)
        {
            _rightControllerHelper.RayHelper =
                Instantiate(RayHelper, Vector3.zero, Quaternion.identity, _rightControllerHelper.transform);
            _rightControllerHelper.RayHelper.gameObject.SetActive(true);
        }

        _leftControllerHelper =
            _cameraRig.leftControllerAnchor.GetComponentInChildren<OVRControllerHelper>();
        if (_leftControllerHelper)
        {
            _leftControllerHelper.RayHelper =
                Instantiate(RayHelper, Vector3.zero, Quaternion.identity, _leftControllerHelper.transform);
            _leftControllerHelper.RayHelper.gameObject.SetActive(true);
        }

        var hands = _cameraRig.GetComponentsInChildren<OVRHand>();
        foreach (var hand in hands)
        {
            hand.RayHelper =
                Instantiate(RayHelper, Vector3.zero, Quaternion.identity, _cameraRig.trackingSpace);
            hand.RayHelper.gameObject.SetActive(true);
        }
    }


    private void OnButtonClicked(int index)
    {
        _chapterManager.StartChapter(index);
        _audioController.PlayOneShot(_buttonSound);
        Hide();
    }
}

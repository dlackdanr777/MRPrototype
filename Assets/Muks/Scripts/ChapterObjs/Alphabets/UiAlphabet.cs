using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;

public class UiAlphabet : MonoBehaviour
{
    [SerializeField] private Transform _player;
    [SerializeField] private ChapterManager _chapterManager;

    [SerializeField] private RectTransform _slotParent;
    [SerializeField] private UIAlphabetSlot _slotPrefab;


    private List<UIAlphabetSlot> _slotList;
    private int _currentIndex;
    private bool _xButtonPressed = false;
    private bool _yButtonPressed = false;
    private bool _joystickLeftMoved= false;
    private bool _joystickRightMoved = false;

    private void Awake()
    {
        _slotList = new List<UIAlphabetSlot>();

        for(int i = 0, cnt = _chapterManager.ChapterLength; i < cnt; i++)
        {
            char alphabet = (char)('A' + i);

            UIAlphabetSlot slot = Instantiate(_slotPrefab, _slotParent);
            slot.Init();
            slot.SetText(alphabet.ToString());
            slot.SetOutline(false);
            _slotList.Add(slot);
        }

        Hide();
    }


    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.S))
        {
            if (!_slotParent.gameObject.activeSelf)
            {
                Show();
                return;
            }

            else
            {
                Debug.Log("����");
                SelectChapter();
            }
        }

        if (Input.GetKeyDown(KeyCode.A))
        {
            ChangeIndex(-1);
        }

        if (Input.GetKeyDown(KeyCode.D))
        {
            ChangeIndex(1);
        }

        ButtonControll();
        JoystickControll();
    }


    public void Show()
    {
        if (_slotParent.gameObject.activeSelf)
            return;

        _slotParent.gameObject.SetActive(true);
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

        _slotParent.gameObject.SetActive(false);
    }


    private void ButtonControll()
    {
        bool xButtonPressed = IsLeftXButtonPressed();
        bool yButtonPressed = IsLeftYButtonPressed();
        if (xButtonPressed && !_xButtonPressed)
        {
            Hide();
        }

        else if (yButtonPressed && !_yButtonPressed)
        {
            if (!_slotParent.gameObject.activeSelf)
            {
                Show();
            }

            else
            {
                SelectChapter();
            }
        }

        _xButtonPressed = xButtonPressed;
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

    private void SelectChapter()
    {
        _chapterManager.StartChapter(_currentIndex);
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
        // ���� ��Ʈ�ѷ� ��ġ ��������
        InputDevice hand = InputDevices.GetDeviceAtXRNode(XRNode.LeftHand);

        // ���̽�ƽ �� �б�
        if (hand.TryGetFeatureValue(CommonUsages.primary2DAxis, out Vector2 joystickPosition))
        {
            // ���̽�ƽ�� �������� ���������� Ȯ�� (-X ����)
            if (joystickPosition.x < -0.5f) // -0.5f�� ������ �ΰ����� ��Ÿ�� (���� ����)
            {
                return true;
            }
        }

        return false;
    }

    private bool IsJoystickRightMoved()
    {
        // ���� ��Ʈ�ѷ� ��ġ ��������
        InputDevice hand = InputDevices.GetDeviceAtXRNode(XRNode.LeftHand);

        // ���̽�ƽ �� �б�
        if (hand.TryGetFeatureValue(CommonUsages.primary2DAxis, out Vector2 joystickPosition))
        {
            if (0.5f < joystickPosition.x)
            {
                return true;
            }
        }

        return false;
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;

public class SprayLeftContoller : MonoBehaviour, IChapterObject
{
    [Header("Components")]
    [SerializeField] private SprayPainter _sprayPainter;
    [SerializeField] private AudioSource _buttonSound;



    [Space]
    [Header("Options")]
    [SerializeField] private Color[] _colors;


    private int _colorIndex = 0;
    private bool _wasXPressed;
    private bool _wasYPressed;


    public void Disabled(ChapterManager manager)
    {
    }

    public void Enabled(ChapterManager manager)
    {
        _colorIndex = 0;
        _sprayPainter.ChangePaintColor(_colors[_colorIndex]);
        _buttonSound.Stop();
    }



    private void Update()
    {
        bool isXPressed = IsLeftXPressed();
        bool isYPressed = IsLeftYPressed();
        if (isXPressed && !_wasXPressed)
        {
            OnChangeColor(-1);
            _buttonSound.Play();
        }

        if(isYPressed && !_wasYPressed)
        {
            OnChangeColor(1);
            _buttonSound.Play();
        }

        if(IsLeftJoystickMovedLeft())
        {
            OnChangeSize(-1);
        }

        else if(IsRightJoystickMovedLeft())
        {
            OnChangeSize(1);
        }

        _wasXPressed = isXPressed;
        _wasYPressed = isYPressed;
    }

    private void OnChangeSize(int dir)
    {
        dir = dir <= 0 ? -1 : 1;
        _sprayPainter.ChangeBrushSize(Time.deltaTime * 0.1f * dir);
        Debug.Log("�귯�� ������ ����" + dir);
    }


    private void OnChangeColor(int dir)
    {
        _colorIndex = (_colorIndex + dir + _colors.Length) % _colors.Length;
        _sprayPainter.ChangePaintColor(_colors[_colorIndex]);

        Debug.Log("�÷� ����" + _colorIndex);
    }



    private bool IsLeftXPressed()
    {
        InputDevice hand = InputDevices.GetDeviceAtXRNode(XRNode.LeftHand);
        if (hand.TryGetFeatureValue(CommonUsages.primaryButton, out bool isPressed))
            return isPressed;

        return false;
    }


    private bool IsLeftYPressed()
    {
        InputDevice hand = InputDevices.GetDeviceAtXRNode(XRNode.LeftHand);
        if (hand.TryGetFeatureValue(CommonUsages.secondaryButton, out bool isPressed))
            return isPressed;

        return false;
    }

    private bool IsLeftJoystickMovedLeft()
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

    private bool IsRightJoystickMovedLeft()
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

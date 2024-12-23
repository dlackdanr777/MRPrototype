using UnityEngine;
using UnityEngine.XR;

public class ChapterChoiceController : MonoBehaviour
{
    [SerializeField] private ChapterChoiceHandControll _leftHandControll;
    [SerializeField] private ChapterChoiceHandControll _rightHandControll;
    [SerializeField] private AudioClip _clickSound;

    private bool _isRightHandEnabled = true;
    private bool _rightTriggerPressed = false;
    private bool _leftTriggerPressed = false;

    private void Start()
    {
        _leftHandControll.enabled = false;
        _rightHandControll.enabled = true;
        _isRightHandEnabled = true;
    }


    public void Update()
    {
        bool rightTriggerPressed = IsRightTriggerPressed();
        bool leftTriggerPressed = IsLeftTriggerPressed();
        if (rightTriggerPressed && !_rightTriggerPressed)
        {
            OnRightTriggerButtonClicked();
        }

        else if (leftTriggerPressed && !_leftTriggerPressed)
        {
            OnLeftTriggerButtonClicked();
        }

        _rightTriggerPressed = rightTriggerPressed;
        _leftTriggerPressed = leftTriggerPressed;
    }



    private void OnRightTriggerButtonClicked()
    {
        if(!_rightHandControll.enabled)
        {
            _rightHandControll.enabled = true;
            _leftHandControll.enabled = false;
            return;
        }

        _rightHandControll.PlayAudio(_clickSound);
        _rightHandControll.InputInteractive();
    }

    private void OnLeftTriggerButtonClicked()
    {
        if (!_leftHandControll.enabled)
        {
            _leftHandControll.enabled = true;
            _rightHandControll.enabled = false;
            return;
        }

        _leftHandControll.PlayAudio(_clickSound);
        _leftHandControll.InputInteractive();
    }



    private bool IsRightTriggerPressed()
    {
        InputDevice rightHand = InputDevices.GetDeviceAtXRNode(XRNode.RightHand);
        if (rightHand.TryGetFeatureValue(CommonUsages.triggerButton, out bool isPressed))
            return isPressed;

        return false;
    }

    private bool IsLeftTriggerPressed()
    {
        InputDevice leftHand = InputDevices.GetDeviceAtXRNode(XRNode.LeftHand);
        if (leftHand.TryGetFeatureValue(CommonUsages.triggerButton, out bool isPressed))
            return isPressed;

        return false;
    }

}

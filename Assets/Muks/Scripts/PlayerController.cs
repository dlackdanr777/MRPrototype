using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;

public class PlayerController : MonoBehaviour
{
    [SerializeField] private ChapterManager _chapterManager;

    private bool _rightAButtonPressed = false;
    private bool _rightBButtonPressed = false;


    void Update()
    {
        bool rightAButtonPressed = IsRightAButtonPressed();
        bool rightBButtonPressed = IsRightBButtonPressed();
        if(rightAButtonPressed && !_rightAButtonPressed)
        {
            ExitScene();
        }

        else if(rightBButtonPressed && !_rightBButtonPressed)
        {
            _chapterManager.NextChapter();
        }

        _rightAButtonPressed = rightAButtonPressed;
        _rightBButtonPressed = rightBButtonPressed;
    }


    private void ExitScene()
    {
        LoadingSceneManager.LoadScene("ChapterChoiceScene");
    }


    private bool IsRightAButtonPressed()
    {
        InputDevice rightHand = InputDevices.GetDeviceAtXRNode(XRNode.RightHand);
        if (rightHand.TryGetFeatureValue(CommonUsages.primaryButton, out bool isPressed))
            return isPressed;

        return false;
    }

    private bool IsRightBButtonPressed()
    {
        InputDevice rightHand = InputDevices.GetDeviceAtXRNode(XRNode.RightHand);
        if (rightHand.TryGetFeatureValue(CommonUsages.secondaryButton, out bool isPressed))
            return isPressed;

        return false;
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;

public class PlayerController : MonoBehaviour
{
    [SerializeField] private ChapterManager _chapterManager;
    [SerializeField] private Transform _objSpawnPos;

    private bool _previousState = false;

    void Update()
    {
        bool primaryButtonPressed = IsPrimaryButtonPressed();

        if(primaryButtonPressed && !_previousState)
        {
            ResetGame();
        }

        _previousState = primaryButtonPressed;
    }


    private void ResetGame()
    {
        _chapterManager.ResetChapter();
    }


    private bool IsPrimaryButtonPressed()
    {
        InputDevice rightHand = InputDevices.GetDeviceAtXRNode(XRNode.RightHand);
        if (rightHand.TryGetFeatureValue(CommonUsages.primaryButton, out bool isPressed))
            return isPressed;

        return false;
    }
}

using System;
using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

public class UIAlphabetSlot : MonoBehaviour
{
    [SerializeField] private UnityEngine.UI.Outline _outLine;
    [SerializeField] private Button _button;
    [SerializeField] private TextMeshProUGUI _text;


    public void Init(UnityAction onButtonClicked)
    {
        _button.onClick.AddListener(onButtonClicked);
    }


    public void SetText(string text)
    {
        _text.text = text;
    }

    public void SetOutline(bool value)
    {
        _outLine.enabled = value;
    }
}

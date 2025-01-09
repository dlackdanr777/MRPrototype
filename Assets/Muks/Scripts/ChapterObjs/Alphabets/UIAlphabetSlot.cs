using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class UIAlphabetSlot : MonoBehaviour
{
    [SerializeField] private UnityEngine.UI.Outline _outLine;
    [SerializeField] private TextMeshProUGUI _text;


    public void Init()
    {

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

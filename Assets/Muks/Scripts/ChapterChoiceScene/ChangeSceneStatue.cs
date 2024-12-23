using Muks.Tween;
using TMPro;
using UnityEngine;

public class ChangeSceneStatue : MonoBehaviour, IChapterChoiceSceneIInteractive
{
    [SerializeField] private string _changeSceneName;
    [SerializeField] private string _name;
    [SerializeField] private TextMeshPro _nameText;
    [SerializeField] private AudioSource _enabledSound;
    [SerializeField] private Outline[] _outLines;

    private bool _isEnabled;


    public void Interact()
    {
        LoadingSceneManager.LoadScene(_changeSceneName);
    }


    public void Enabled()
    {
        if (_isEnabled)
            return;

        Debug.Log("È°¼º");
        _isEnabled = true;
        _nameText.gameObject.SetActive(true);
        _nameText.TweenStop();
        _nameText.text = _name;
        _nameText.transform.localScale = new Vector3(0.3f, 0.3f, 0.3f);
        _nameText.TweenScale(Vector3.one, 0.3f, Ease.OutBack);
        _enabledSound.Play();
        if (_outLines.Length <= 0)
            return;

        for (int i = 0, cnt = _outLines.Length; i < cnt; ++i)
        {
            _outLines[i].Enabled();
        }
    }


    public void Disabled()
    {
        _isEnabled = false;
        _nameText.gameObject.SetActive(true);
        _nameText.TweenStop();
        _nameText.transform.localScale = Vector3.one;
        _nameText.TweenScale(new Vector3(0.3f, 0.3f, 0.3f), 0.3f, Ease.InBack).OnComplete(() => _nameText.gameObject.SetActive(false));

        if (_outLines.Length <= 0)
            return;

        for (int i = 0, cnt = _outLines.Length; i < cnt; ++i)
        {
            _outLines[i].Disabled();
        }
    }



    public void InteraciveUpdate()
    {
    }


    public void Start()
    {
        _nameText.gameObject.SetActive(false);
        _enabledSound.Stop();
        _isEnabled = false;
        for (int i = 0, cnt = _outLines.Length; i < cnt; ++i)
        {
            _outLines[i].OnCreateOutlineHandler += Disabled;
        }
    }
}

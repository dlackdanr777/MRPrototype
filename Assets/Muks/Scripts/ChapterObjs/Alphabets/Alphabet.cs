using UnityEngine;

public class Alphabet : MonoBehaviour, IChapterObject
{
    [SerializeField] private GameObject _player;
    [SerializeField] private AlphabetStatue[] _alphabetStatues;


    [Header("Audios")]
    [SerializeField] private AudioSource _audioSource;
    [SerializeField] private AudioClip _clickAudio;

    private GameObject _currentAnimeObj;

    public void Enabled(ChapterManager manager)
    {
        if (_currentAnimeObj != null)
            Destroy(_currentAnimeObj);

        Vector3 pos = _player.transform.position + _player.transform.forward;
        pos.y = manager.GetFloorCenterPos().y;
        transform.position = pos;

        Vector3 dir = (transform.position - _player.transform.position).normalized;
        float angle = Mathf.Atan2(dir.x, dir.z) * Mathf.Rad2Deg;
        transform.rotation = Quaternion.Euler(0, angle, 0);

    }

    public void Disabled(ChapterManager manager)
    {
        _audioSource.Stop();
    }

    private void Awake()
    {
        for(int i = 0, cnt = _alphabetStatues.Length; i < cnt; i++)
        {
            _alphabetStatues[i].OnTriggerEnterHandler += OnTriggerEnterEvent;
        }

    }

    private void OnTriggerEnterEvent(GameObject animeObj, AudioClip clip)
    {
        if (_currentAnimeObj != null)
            Destroy(_currentAnimeObj);


        Vector3 dir = (_player.transform.position - transform.position).normalized;
        float angle = Mathf.Atan2(dir.x, dir.z) * Mathf.Rad2Deg;
        Quaternion rot = Quaternion.Euler(0, angle, 0);
        _currentAnimeObj = Instantiate(animeObj, transform.position + transform.forward * 2, rot, transform);
        _currentAnimeObj.transform.localScale = Vector3.one * 1.5f;

        _audioSource.Stop();
        _audioSource.PlayOneShot(_clickAudio);
        _audioSource.clip = clip;
        _audioSource.Play();
    }
}

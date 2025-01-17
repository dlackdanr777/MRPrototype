using UnityEngine;

public class Alphabet : MonoBehaviour, IChapterObject
{
    [SerializeField] private GameObject _player;
    [SerializeField] private AlphabetStatue[] _alphabetStatues;


    [Header("Audios")]
    [SerializeField] private AudioController _audioController;
    [SerializeField] private AudioClip _clickAudio;

    private GameObject _currentAnimeObj;

    public void Enabled(ChapterManager manager)
    {
        if (_currentAnimeObj != null)
            Destroy(_currentAnimeObj);

        Vector3 playerPosition = _player.transform.position;
        Vector3 forwardDirection = _player.transform.forward;
        Vector3 targetPosition = new Vector3(playerPosition.x + forwardDirection.x * 0.7f, manager.GetFloorCenterPos().y, playerPosition.z + forwardDirection.z * 0.7f);
        transform.position = targetPosition;

        Vector3 dir = (transform.position - _player.transform.position).normalized;
        float angle = Mathf.Atan2(dir.x, dir.z) * Mathf.Rad2Deg;
        transform.rotation = Quaternion.Euler(0, angle, 0);

    }

    public void Disabled(ChapterManager manager)
    {
        _audioController.Stop();
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

        _audioController.Stop();
        _audioController.PlayOneShot(_clickAudio);
        _audioController.Play(clip, 0.5f);
    }
}

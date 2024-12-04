using UnityEngine;


[System.Serializable]
public class GrabObjectCollisionSoundData
{
    //해당 소리가 나는 최소 속도
    [Range(0, 100)] [SerializeField] private float _minSpeed;
    public float MinSpeed => _minSpeed;

    // 해당 소리가 나는 최대 속도
    [Range(0, 100)][SerializeField] private float _maxSpeed;
    public float MaxSpeed => _maxSpeed;

    [SerializeField] private AudioClip _audioClip;
    public AudioClip AudioClip => _audioClip;
}


public class GrabObject : MonoBehaviour
{
    [SerializeField] private Rigidbody _rigidBody;
    public Rigidbody Rigidbody => _rigidBody;

    [SerializeField] private AudioSource _audioSource;
    [SerializeField] private GrabObjectCollisionSoundData[] _soundDatas;

    private bool _isGrab = false;
    public bool IsGrab => _isGrab;  

    public void SetGrabState(bool isGrab)
    {
        _isGrab = isGrab;
    }

    private void OnCollisionEnter(Collision collision)
    {
        // Rigidbody의 속도를 기반으로 충돌 감지
        for(int i = 0, cnt = _soundDatas.Length; i < cnt; ++i)
        {
            if (!_isGrab && _soundDatas[i].MinSpeed <= _rigidBody.velocity.magnitude && _rigidBody.velocity.magnitude <= _soundDatas[i].MaxSpeed)
            {
                _audioSource?.PlayOneShot(_soundDatas[i].AudioClip);
                return;
            }
        }
    }

}

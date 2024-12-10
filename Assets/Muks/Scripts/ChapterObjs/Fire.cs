using UnityEngine;

public class Fire : MonoBehaviour, IChapterObject
{

    [SerializeField] private GameObject[] _fires;
    [SerializeField] private AudioSource _fireSound;
    [Range(1f, 10f)] [SerializeField] private int _maxGauge;

    [Space]
    [Header("Size Option")]
    [SerializeField] private bool _drawGizmos;
    [SerializeField] private Vector3 _size;
    [SerializeField] private Vector3 _center;


    private float _currentGauge;

    public void Enabled(ChapterManager manager)
    {
        SetPos(manager);
        SetFire();
    }

    public void Disabled(ChapterManager manager)
    {
    }

    public void SetFire()
    {
        _currentGauge = _maxGauge;
        for(int i = 0, cnt =  _fires.Length; i < cnt; ++i)
        {
            _fires[i].gameObject.SetActive(true);
        }
        _fireSound.volume = 1f;
    }


    public void PutOutTheFire(float value)
    {
        if (_currentGauge <= 0)
            return;

        _currentGauge -= value;
        int fireCount = _fires.Length;
        int gaugePerFire = _maxGauge / fireCount;
        _fireSound.volume = _currentGauge <= 0 ? 0 : _currentGauge / _maxGauge;
        for (int i = 0; i < fireCount; ++i)
        {
            if(_currentGauge <= i * gaugePerFire)
            {
                _fires[i].SetActive(false);
            }
        }
    }


    private void Awake()
    {
        SetFire();
    }


    private void OnDrawGizmos()
    {
        if (!_drawGizmos)
            return;

        Gizmos.color = Color.green;
        Vector3 boxCenter = transform.position + _center;
        Gizmos.DrawWireCube(boxCenter, _size);
    }

    private void SetPos(ChapterManager manager)
    {
        bool isPositionValid = false;
        int cnt = 0;
        while (!isPositionValid)
        {
            // 새로운 위치 설정

            Vector3 pos = manager.GetRandomCornerPos();
            Vector3 direction = (manager.GetFloorCenterPos() - pos).normalized;
            direction.y = 0;
            float offset = Mathf.Min(_size.x, _size.z) / 2.3f;
            transform.position = pos + direction * offset;

            // 박스 중심 위치 계산
            Vector3 boxCenter = transform.position + _center;

            // 충돌체 확인 (Floor 태그 제외)
            Collider[] colliders = Physics.OverlapBox(boxCenter, _size / 2);
            isPositionValid = true;

            foreach (var collider in colliders)
            {
                if (collider.gameObject != gameObject && collider.gameObject.layer != LayerMask.NameToLayer("Floor") && collider.gameObject.layer != LayerMask.NameToLayer("Wall"))
                {
                    // Floor 레이어가 아니면 충돌로 간주
                    isPositionValid = false;
                    break;
                }
            }

            if (10 <= cnt)
            {
                transform.position = manager.GetFloorCenterPos();
                return;
            }
            cnt++;
        }
    }
}

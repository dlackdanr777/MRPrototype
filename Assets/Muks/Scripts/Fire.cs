using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Fire : MonoBehaviour
{
    [SerializeField] private bool _drawGizoms;
    [SerializeField] private GameObject[] _fires;
    [SerializeField] private Vector3 _size;
    public Vector3 Size => _size;
    [Range(1f, 100f)] [SerializeField] private int _maxGauge;


    private int _currentGauge;
    public void Init()
    {
        _currentGauge = _maxGauge;
        for(int i = 0, cnt =  _fires.Length; i < cnt; ++i)
        {
            _fires[i].gameObject.SetActive(true);
        }
    }


    public void PutOutTheFire()
    {
        if (_currentGauge <= 0)
            return;

        _currentGauge--;
        int fireCount = _fires.Length;
        int gaugePerFire = _maxGauge / fireCount;

        for(int i = 0; i < fireCount; ++i)
        {
            if(_currentGauge <= i * gaugePerFire)
            {
                _fires[i].SetActive(false);
            }
        }
    }

    private void Awake()
    {
        Init();
    }


    private void OnDrawGizmos()
    {
        if (!_drawGizoms)
            return;

        Gizmos.color = Color.green;
        Vector3 center = transform.position;
        Vector3 size = _size;
        center.y += size.y / 2;
        Gizmos.DrawWireCube(center, size);
    }
}

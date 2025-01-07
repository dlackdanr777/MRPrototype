using Muks.Tween;
using System;
using UnityEngine;

public class AlphabetStatue : MonoBehaviour
{
    public event Action<GameObject, AudioClip> OnTriggerEnterHandler;

    [SerializeField] private GameObject _animeObj;
    [SerializeField] private AudioClip _clip;


    private Vector3 _tmpScale;
    private void Awake()
    {
        _tmpScale = transform.localScale;
    }


    private void OnTriggerEnter(Collider other)
    {
        if (!other.gameObject.CompareTag("Hand"))
            return;

        gameObject.TweenStop();
        gameObject.transform.localScale = _tmpScale;
        gameObject.TweenScale(_tmpScale * 0.98f, 0.2f, Ease.OutBack).OnComplete(() => gameObject.TweenScale(_tmpScale, 0.2f, Ease.OutBack));
        OnTriggerEnterHandler?.Invoke(_animeObj, _clip);
    }
}

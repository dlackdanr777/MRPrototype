using Muks.Tween;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioController : MonoBehaviour
{
    [SerializeField] private AudioSource _audioSource;


    private Coroutine _playCoroutine;
    private Coroutine _playOneShotCoroutine;

    void Start()
    {
        _audioSource.Stop();
    }


    public void Stop()
    {
        if (_playCoroutine != null)
            StopCoroutine(_playCoroutine);

        if (_playOneShotCoroutine != null)
            StopCoroutine(_playOneShotCoroutine);

        _audioSource.Stop();
    }


    public void Play(AudioClip clip, float waitTime = 0)
    {
        if (_playCoroutine != null)
            StopCoroutine(_playCoroutine);

        _playCoroutine = StartCoroutine(WaitPlayRoutine(clip, waitTime));
    }


    public void PlayOneShot(AudioClip clip)
    {
        _audioSource.PlayOneShot(clip);
    }

    public void PlayOneShot(AudioClip clip, float waitTime = 0)
    {
        if(_playOneShotCoroutine != null)
            StopCoroutine(_playOneShotCoroutine);
        _playOneShotCoroutine = StartCoroutine(WaitPlayOneShotRoutine(clip,waitTime));
    }


    private IEnumerator WaitPlayRoutine(AudioClip clip, float waitTime)
    {
        float timer = 0;
        while(timer < waitTime)
        {
            timer += Time.deltaTime;
            yield return null;
        }

        _audioSource.clip = clip;
        _audioSource.Play();
    }


    private IEnumerator WaitPlayOneShotRoutine(AudioClip clip, float waitTime)
    {
        float timer = 0;
        while (timer < waitTime)
        {
            timer += Time.deltaTime;
            yield return null;
        }

        PlayOneShot(clip);
    }
}

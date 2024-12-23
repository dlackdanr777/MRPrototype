using Muks.Tween;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static Oculus.Interaction.Locomotion.LocomotionEvent;

public class Planet : MonoBehaviour, IChapterObject
{
    [SerializeField] private Transform _planetObj;
    [SerializeField] private float _rotationTime = 60f;
    [SerializeField] private bool _isRightRotation;


    private TweenData _tweenWait;

    public void Disabled(ChapterManager manager)
    {
        _planetObj.TweenStop();

        if (_tweenWait != null)
            _tweenWait.TweenStop();
    }

    public void Enabled(ChapterManager manager)
    {
        _planetObj.TweenStop();
        if (_tweenWait != null)
            _tweenWait.TweenStop();

        Vector3 pos = manager.GetFloorCenterPos();
        _planetObj.transform.position = pos + new Vector3(0, 5f, 0);
        _planetObj.TweenMove(pos + new Vector3(0, 1.5f, 0), 4, Ease.Smoothstep).OnComplete(() =>
        {
            _tweenWait = Tween.Wait(0.1f, () =>
            {
                _planetObj.TweenMove(pos + new Vector3(0, 1.25f, 0), 8, Ease.Smoothstep).Loop(LoopType.Yoyo);
            });
        });

    }

    private void Update()
    {
        float degreesPerSecond = _isRightRotation ? -360f / _rotationTime : 360f / _rotationTime;
        _planetObj.Rotate(Vector3.up, degreesPerSecond * Time.deltaTime, Space.Self);
    }
}

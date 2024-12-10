using Muks.Tween;
using UnityEngine;

public class CatIdleState : CatState
{

    public CatIdleState(Cat cat, CatStateMachine stateMachine) : base(cat, stateMachine){}

    private const float STOP_TIME = 1f;

    private TweenData _tween;

    private bool _isWalk;
    private float _stopTime;
    private float _stopTimer;

    public override void OnStart()
    {
        //_cat.HeadTracking.SetEnabled(false);
        _isWalk = false;
        _stopTime = STOP_TIME * Random.Range(1f, 2f);
        _stopTimer = 0;
        _tween = Tween.Wait(0.2f, () =>
        {
            _isWalk = true;
            _cat.SetNavmeshEnable(true);
        });
        //_cat.HeadTracking.SetEnabled(true);
        //_cat.HeadTracking.SetTarget(_cat.TargetPlayer);
        _cat.OnTriggerEnterHandler += OnTriggerEnterEvent;
        _cat.OnTriggerEixtHandler += OnTriggerExitEvent;
    }

    public override void OnExit()
    {
        _tween?.TweenStop();
        _stopTimer = 0;
        _isWalk = false;
        _cat.OnTriggerEnterHandler -= OnTriggerEnterEvent;
        _cat.OnTriggerEixtHandler -= OnTriggerExitEvent;
    }

    public override void OnUpdate()
    {
    }

    public override void OnStateUpdate()
    {

    }

    public override void OnFixedUpdate()
    {
        if (_isWalk)
            _cat.Tracking();

        if(_cat.IsReachedDestination())
        {
            _stopTimer += Time.deltaTime;
            if(_stopTime <= _stopTimer)
            {
                _cat.ChangeState(AnimalState.Sit);
            }
        }
        else
        {
            _stopTimer = 0;
        }
    }


    private void OnTriggerEnterEvent(Collider other)
    {
        if (other.tag == "Hand")
        {
            _cat.ChangeState(AnimalState.Touch);
        }
    }


    private void OnTriggerExitEvent(Collider other)
    {
        if (other.tag == "Hand")
        {
            _cat.ChangeState(AnimalState.Idle);
        }
    }
}

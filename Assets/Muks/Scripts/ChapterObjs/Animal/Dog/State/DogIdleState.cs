using Muks.Tween;
using UnityEngine;

public class DogIdleState : DogState
{

    public DogIdleState(Dog dog, DogStateMachine stateMachine) : base(dog, stateMachine){}
    public TweenData _tween;
    public override void OnStart()
    {
        _tween = Tween.Wait(0.2f, () => _dog.SetNavmeshEnable(true));
        _dog.HeadTracking.SetEnabled(true);
        _dog.HeadTracking.SetTarget(_dog.TargetPlayer);
        _dog.OnTriggerEnterHandler += OnTriggerEnterEvent;
        _dog.OnTriggerEixtHandler += OnTriggerExitEvent;
        GrabGun.OnShootObjectHandler += OnShootGrabObectEvent;
    }

    public override void OnExit()
    {
        _tween?.TweenStop();
        _dog.OnTriggerEnterHandler -= OnTriggerEnterEvent;
        _dog.OnTriggerEixtHandler -= OnTriggerExitEvent;
        GrabGun.OnShootObjectHandler -= OnShootGrabObectEvent;
    }

    public override void OnUpdate()
    {
    }

    public override void OnStateUpdate()
    {

    }

    public override void OnFixedUpdate()
    {
        _dog.Tracking(_dog.TargetPlayer);
    }


    private void OnTriggerEnterEvent(Collider other)
    {
        if (other.tag == "Hand")
        {
            _dog.ChangeState(AnimalState.Touch);
        }
    }


    private void OnTriggerExitEvent(Collider other)
    {
        if (other.tag == "Hand")
        {
            _dog.ChangeState(AnimalState.Idle);
        }
    }


    private void OnShootGrabObectEvent(GrabObject obj)
    {
        _dog.SetTargetGrabObject(obj);
        _dog.ChangeState(AnimalState.TrackingObject);
    }
}

using Muks.Tween;
using UnityEngine;

public class DogSitState : DogState
{

    public DogSitState(Dog dog, DogStateMachine stateMachine) : base(dog, stateMachine){}

    public override void OnStart()
    {
        _dog.SetNavmeshEnable(false);
        _dog.HeadTracking.SetEnabled(true);
        _dog.HeadTracking.SetTarget(_dog.TargetPlayer);
        _dog.OnTriggerEnterHandler += OnTriggerEnterEvent;
        _dog.OnTriggerEixtHandler += OnTriggerExitEvent;
    }

    public override void OnExit()
    {
        _dog.OnTriggerEnterHandler -= OnTriggerEnterEvent;
        _dog.OnTriggerEixtHandler -= OnTriggerExitEvent;
    }

    public override void OnUpdate()
    {
    }

    public override void OnStateUpdate()
    {

    }

    public override void OnFixedUpdate()
    {
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
}

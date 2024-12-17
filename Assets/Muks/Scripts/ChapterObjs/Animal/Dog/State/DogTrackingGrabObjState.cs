using UnityEngine;

public class DogTrackingGrabObjState : DogState
{

    public DogTrackingGrabObjState(Dog dog, DogStateMachine stateMachine) : base(dog, stateMachine){}


    public override void OnStart()
    {
        if(_dog.TargetGrabObj == null)
        {
            _dog.ChangeState(AnimalState.Idle);
            return;
        }

        _dog.SetNavmeshEnable(true);
        _dog.HeadTracking.SetEnabled(true);
        _dog.HeadTracking.SetTarget(_dog.TargetGrabObj.transform);
        _dog.PlayAudio();
        GrabGun.OnRecoveringObjectHandler += OnRecoveringObjectEvent;
    }


    public override void OnExit()
    {
        GrabGun.OnRecoveringObjectHandler -= OnRecoveringObjectEvent;
    }

    public override void OnUpdate()
    {
    }

    public override void OnStateUpdate()
    {
        if (_dog.TargetGrabObj == null)
            return;

        if (Vector3.Distance(_dog.TargetGrabObj.transform.position, _dog.transform.position) < 0.3f)
        {
            _dog.ChangeState(AnimalState.CollectObject);
            return;
        }

    }

    public override void OnFixedUpdate()
    {
        if (_dog.TargetGrabObj == null)
            return;

        _dog.Tracking(_dog.TargetGrabObj.transform);
    }

    private void OnRecoveringObjectEvent(GrabObject obj)
    {
        if (obj != _dog.TargetGrabObj)
            return;

        _dog.ChangeState(AnimalState.Idle);
        _dog.SetTargetGrabObject(null);
    }
}

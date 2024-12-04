using Muks.Tween;
using UnityEngine;

public class DogCollectGrabObjState : DogState
{

    public DogCollectGrabObjState(Dog dog, DogStateMachine stateMachine) : base(dog, stateMachine){}


    public override void OnStart()
    {
        if(_dog.TargetGrabObj == null)
        {
            _dog.ChangeState(AnimalState.Idle);
            return;
        }

        _dog.SetNavmeshEnable(true);
        _dog.HeadTracking.SetEnabled(true);
        _dog.HeadTracking.SetTarget(_dog.transform);
        _dog.GrabObject(_dog.TargetGrabObj);

        /*        _dog.TargetGrabObj.Rigidbody.velocity = Vector3.zero;
                _dog.TargetGrabObj.SetGrabState(true);
                _dog.SetNavmeshEnable(false);
                _dog.HeadTracking.SetEnabled(true);
                _dog.HeadTracking.SetTarget(_dog.TargetGrabObj.transform);
                GrabGun.OnRecoveringObjectHandler += OnRecoveringObjectEvent;

                Tween.Wait(0.3f, () =>
                {
                    _dog.SetNavmeshEnable(true);
                    _dog.HeadTracking.SetEnabled(true);
                    _dog.HeadTracking.SetTarget(_dog.transform);
                    _dog.GrabObject(_dog.TargetGrabObj);
                });*/
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
        {
            _dog.ChangeState(AnimalState.Idle);
            return;
        }

        Vector3 _playerPos = _dog.TargetPlayer.transform.position;
        Vector3 _dogPos = _dog.transform.position;
        _playerPos.y = 0;
        _dogPos.y = 0;

        if (Vector3.Distance(_playerPos, _dogPos) < 0.7f)
        {
            _dog.GrabObject(null);
            _dog.ChangeState(AnimalState.Idle);
            _dog.SetTargetGrabObject(null);
            return;
        }
    }

    public override void OnFixedUpdate()
    {
        if (_dog.TargetGrabObj == null)
            return;

        if (!_dog.NavmeshEnabled)
            return;

        _dog.Tracking(_dog.TargetPlayer);
    }

    private void OnRecoveringObjectEvent(GrabObject obj)
    {
        if (obj != _dog.TargetGrabObj)
            return;

        _dog.ChangeState(AnimalState.Idle);
        _dog.SetTargetGrabObject(null);
    }
}

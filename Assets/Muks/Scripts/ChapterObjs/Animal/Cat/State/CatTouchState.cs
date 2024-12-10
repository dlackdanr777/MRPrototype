using UnityEngine;

public class CatTouchState : CatState
{

    public CatTouchState(Cat cat, CatStateMachine stateMachine) : base(cat, stateMachine){}

    public override void OnStart()
    {
        _cat.SetNavmeshEnable(false);
        //_cat.HeadTracking.SetEnabled(true);
        //_cat.HeadTracking.SetTarget(_cat.HeadTarget);
        _cat.OnTriggerEnterHandler += OnTriggerEnterEvent;
        _cat.OnTriggerEixtHandler += OnTriggerExitEvent;
    }

    public override void OnExit()
    {
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

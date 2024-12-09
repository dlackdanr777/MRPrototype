using UnityEngine;

public class CatSitState : CatState
{
    public CatSitState(Cat cat, CatStateMachine stateMachine) : base(cat, stateMachine){}

    private const float GROOMING_TIME = 5;

    private float _groomingTime = 0;
    private Vector2 _randomRangeTime= new Vector2(0.5f, 1.5f);
    private float _groomingTimer;

    public override void OnStart()
    {
       /* _cat.HeadTracking.SetEnabled(true);
        _cat.HeadTracking.SetTarget(_cat.HeadTarget);*/
        ResetTime();
        _cat.SetNavmeshEnable(true);
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
        _groomingTimer += Time.deltaTime;
        if(_groomingTime <= _groomingTimer)
        {
            _cat.Animator.SetTrigger("Grooming");
            ResetTime();
        }
    }

    public override void OnFixedUpdate()
    {
        if(!_cat.IsReachedDestination())
        {
            _cat.SetNavmeshEnable(true);
            _cat.ChangeState(AnimalState.Idle);
        }
    }


    private void ResetTime()
    {
        _groomingTime = GROOMING_TIME * Random.Range(_randomRangeTime.x, _randomRangeTime.y);
        _groomingTimer = 0;
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

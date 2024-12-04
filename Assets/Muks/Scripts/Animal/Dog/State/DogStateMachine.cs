using System.Collections.Generic;
using UnityEngine;

public class DogStateMachine
{
    private Dog _dog;
    public AnimalState _currentAnimalState = AnimalState.Length;
    private DogState _currentState;
    private Dictionary<AnimalState, DogState> _stateDic;

    public DogStateMachine(Dog dog)
    {
        _dog = dog;
        _dog.OnStateChangeHandler += OnChangeStateEvent;
        _stateDic = new Dictionary<AnimalState, DogState> 
        {
            { AnimalState.Idle, new DogIdleState(_dog, this) },
            { AnimalState.Sit, new DogSitState(_dog, this) },
            {AnimalState.TrackingObject, new DogTrackingGrabObjState(_dog, this) },
            {AnimalState.CollectObject, new DogCollectGrabObjState(_dog, this) },
        };
        ChangeState(AnimalState.Idle);
    }

     ~DogStateMachine()
    {
        _dog.OnStateChangeHandler -= OnChangeStateEvent;
    }

    public void OnUpdate()
    {
        _currentState?.OnUpdate();
        _currentState?.OnStateUpdate();
    }


    public void OnFixedUpdate()
    {
        _currentState?.OnFixedUpdate();
    }


    public void ChangeState(AnimalState nextState)
    {
        if (_currentAnimalState == nextState)
            return;

        if(!_stateDic.TryGetValue(nextState, out DogState nextDogState))
        {
            Debug.LogError("현재 state의 맞는 행동 클래스가 존재하지 않습니다: " + nextState);
            return;
        }

        _currentState?.OnExit();
        _currentAnimalState = nextState;
        _currentState = nextDogState;
        _currentState.OnStart();
    }


    private void OnChangeStateEvent(AnimalState state)
    {
        ChangeState(state);
    }
}

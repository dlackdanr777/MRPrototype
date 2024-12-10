using System.Collections.Generic;
using UnityEngine;

public class CatStateMachine
{
    private Cat _cat;
    public AnimalState _currentAnimalState = AnimalState.Length;
    private CatState _currentState;
    private Dictionary<AnimalState, CatState> _stateDic;

    public CatStateMachine(Cat cat)
    {
        _cat = cat;
        _cat.OnStateChangeHandler += OnChangeStateEvent;
        _stateDic = new Dictionary<AnimalState, CatState> 
        {
            { AnimalState.Idle, new CatIdleState(_cat, this) },
            { AnimalState.Sit, new CatSitState(_cat, this) },
            {AnimalState.Touch, new CatTouchState(_cat, this) },
        };
        ChangeState(AnimalState.Idle);
    }

     ~CatStateMachine()
    {
        _cat.OnStateChangeHandler -= OnChangeStateEvent;
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

        if(!_stateDic.TryGetValue(nextState, out CatState nextCatState))
        {
            Debug.LogError("현재 state의 맞는 행동 클래스가 존재하지 않습니다: " + nextState);
            return;
        }

        _currentState?.OnExit();
        _currentAnimalState = nextState;
        _currentState = nextCatState;
        _currentState.OnStart();
    }


    private void OnChangeStateEvent(AnimalState state)
    {
        ChangeState(state);
    }
}

public abstract class DogState : IState
{
    protected Dog _dog;
    protected DogStateMachine _stateMachine;

    public DogState(Dog dog, DogStateMachine stateMachine)
    {
        _dog = dog;
        _stateMachine = stateMachine;
    }

    public abstract void OnExit();

    public abstract void OnFixedUpdate();

    public abstract void OnStart();

    public abstract void OnStateUpdate();

    public abstract void OnUpdate();
}

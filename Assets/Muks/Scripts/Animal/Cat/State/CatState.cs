public abstract class CatState : IState
{
    protected Cat _cat;
    protected CatStateMachine _stateMachine;

    public CatState(Cat cat, CatStateMachine stateMachine)
    {
        _cat = cat;
        _stateMachine = stateMachine;
    }

    public abstract void OnExit();

    public abstract void OnFixedUpdate();

    public abstract void OnStart();

    public abstract void OnStateUpdate();

    public abstract void OnUpdate();
}

public interface IState
{
    public void OnStart();
    public void OnUpdate();
    public void OnFixedUpdate();
    public void OnStateUpdate();
    public void OnExit();
}

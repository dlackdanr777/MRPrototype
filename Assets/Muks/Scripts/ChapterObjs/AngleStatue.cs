using Muks.Tween;
using UnityEngine;

public class AngleStatue : MonoBehaviour, IChapterObject
{
    [SerializeField] private Transform _player;
    
    public void Enabled(ChapterManager manager)
    {
        gameObject.TweenStop();
        Vector3 pos = manager.GetFloorCenterPos();
        gameObject.transform.position = pos + new Vector3(0, -2.5f, 0);
        gameObject.TweenMove(pos, 4, Ease.Smoothstep);

        Vector3 direction = _player.transform.position - transform.position;
        direction.y = 0;
        direction.Normalize();
        transform.rotation = Quaternion.LookRotation(direction);
    }

    public void Disabled(ChapterManager manager)
    {
        gameObject.TweenStop();
    }


}

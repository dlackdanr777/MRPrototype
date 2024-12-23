using UnityEngine;

public class City : MonoBehaviour, IChapterObject
{
    public void Disabled(ChapterManager manager)
    {
    }

    public void Enabled(ChapterManager manager)
    {
        transform.position = manager.GetFloorCenterPos();
        transform.rotation = Quaternion.Euler(0, manager.GetFloorRotationY(), 0);
    }
}

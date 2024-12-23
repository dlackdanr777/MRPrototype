using UnityEngine;

public class CartoonTown : MonoBehaviour, IChapterObject
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

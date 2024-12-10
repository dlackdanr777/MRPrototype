using UnityEngine;

public class KobyAndTori : MonoBehaviour, IChapterObject
{
    public void Enabled(ChapterManager manager)
    {
        transform.position = manager.GetFloorCenterPos();
    }

    public void Disabled(ChapterManager manager)
    {
    }



}

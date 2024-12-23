using UnityEngine;

public class StatueParent : MonoBehaviour, IChapterObject
{
    public void Disabled(ChapterManager manager)
    {

    }

    public void Enabled(ChapterManager manager)
    {
/*        float angleY = manager.GetFloorRotationY();
        if (angleY < 0)
            angleY = angleY % 60;

        else if (0 < angleY)
            angleY = angleY % 60;
        transform.rotation = Quaternion.Euler(0, angleY, 0);*/
    }
}

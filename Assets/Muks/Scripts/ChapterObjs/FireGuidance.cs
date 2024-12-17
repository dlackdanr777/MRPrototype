using UnityEngine;

public class FireGuidance : MonoBehaviour, IChapterObject
{
    [SerializeField] private Fire _fire;

    public void Enabled(ChapterManager manager)
    {
        transform.position = manager.GetFloorCenterPos();
        Vector3 directionToFire = _fire.transform.position - transform.position;
        directionToFire.y = 0;
        transform.rotation = Quaternion.LookRotation(directionToFire);
    }

    public void Disabled(ChapterManager manager)
    {
    }
}

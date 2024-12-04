using Meta.XR.MRUtilityKit;
using UnityEngine;

public class FloorDetectManager : MonoBehaviour
{
    [SerializeField] private Transform _detecterTr;
    [SerializeField] private LayerMask _targetLayer;

    public float GetFloorPosY()
    {
        Ray ray = new Ray(_detecterTr.position, Vector3.down);

        if(Physics.Raycast(ray, out RaycastHit hit, 100, _targetLayer))
        {
            return hit.point.y;
        }

        else
        {
            return -100000;
        }
    }
}

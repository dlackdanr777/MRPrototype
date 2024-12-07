using Meta.XR.MRUtilityKit;
using Unity.AI.Navigation;
using UnityEngine;
using UnityEngine.Events;

public class RuntimeNavMeshBake : MonoBehaviour
{
    [SerializeField] private NavMeshSurface _surface;
    [SerializeField] private UnityEvent _createNaveMeshEvent;

    public void BakeNavMesh()
    {
        Invoke("InvokeNavMesh", 0.5f);
    }


    private void InvokeNavMesh()
    {
        if (_surface == null)
        {
            Debug.LogError("navMeshSurface가 존재하지 않습니다.");
            return;
        }

        MRUKRoom room = FindAnyObjectByType<MRUKRoom>();
        GameObject floor = room.FloorAnchor.gameObject;
        floor.layer = LayerMask.NameToLayer("Floor");
        foreach(var child in floor.GetComponentsInChildren<Transform>())
            child.gameObject.layer = LayerMask.NameToLayer("Floor");

        _surface.BuildNavMesh();
        _createNaveMeshEvent?.Invoke();
    }
}

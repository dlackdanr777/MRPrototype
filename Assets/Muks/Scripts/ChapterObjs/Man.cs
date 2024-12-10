using UnityEngine;

public class Man : MonoBehaviour, IChapterObject
{
    [SerializeField] private bool _drawGizmos;
    [SerializeField] private Vector3 _size;
    [SerializeField] private Vector3 _center;

    public void Disabled(ChapterManager manager)
    {

    }

    public void Enabled(ChapterManager manager)
    {
        SetPos(manager);
    }


    private void SetPos(ChapterManager manager)
    {
        bool isPositionValid = false;
        int cnt = 0;
        Vector3 floorCenter = manager.GetFloorCenterPos();

        while (!isPositionValid)
        {
            // 새로운 위치 설정
            transform.position = manager.GetRandomFloorPos();
            Vector3 dir = (floorCenter - transform.position).normalized;

            // Y축 회전만 적용
            float angle = Mathf.Atan2(dir.x, dir.z) * Mathf.Rad2Deg;
            transform.rotation = Quaternion.Euler(0, angle, 0);

            // 박스 중심 위치 계산
            Vector3 boxCenter = transform.position + _center;
            Quaternion boxRotation = transform.rotation;

            // 충돌체 확인 (Floor 태그 제외)
            Collider[] colliders = Physics.OverlapBox(boxCenter, _size / 2, boxRotation);
            isPositionValid = true;

            foreach (var collider in colliders)
            {
                if (collider.gameObject != gameObject && collider.gameObject.layer != LayerMask.NameToLayer("Floor"))
                {
                    // Floor 레이어가 아니면 충돌로 간주
                    isPositionValid = false;
                    break;
                }
            }

            if (10 <= cnt)
            {
                transform.position = floorCenter;
                return;
            }
            cnt++;
        }
    }

    private void OnDrawGizmos()
    {
        if (!_drawGizmos)
            return;

        Gizmos.color = Color.green;
        Vector3 boxCenter = transform.position + _center;
        Gizmos.DrawWireCube(boxCenter, _size);
    }
}

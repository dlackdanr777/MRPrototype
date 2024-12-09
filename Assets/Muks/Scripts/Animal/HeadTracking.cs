using UnityEngine;
using UnityEngine.Animations.Rigging;

public class HeadTracking : MonoBehaviour
{
    [Header("Components")]
    [SerializeField] private Transform _headTr;
    [SerializeField] private Transform _target;
    [SerializeField] private RigBuilder _rigBuilder;
    [SerializeField] private MultiAimConstraint _headConstraint;

    [Space]
    [Header("Settings")]
    [SerializeField] private Vector3 _correctionAngle;
    [Range(-180f, 0)][SerializeField] private float _minHorizontalAngle = -100;
    [Range(0f, 180f)] [SerializeField] private float _maxHorizontalAngle = 100;
    [Range(-100f, 0f)][SerializeField] private float _minVerticalAngle = -20;
    [Range(0f, 100f)][SerializeField] private float _maxVerticalAngle = 90;
    [Range(0f, 10f)][SerializeField] private float _weightChangeSpeed = 1f;

    [Space]
    [Header("Debug")]
    [SerializeField] private bool _gizmosEnabled = true;

    private bool _isEnabled = true;

    private void Update()
    {
        if (_target == null)
            return;

        if (!_isEnabled)
        {
            if(0 < _headConstraint.weight)
                Mathf.MoveTowards(_headConstraint.weight, 0f, _weightChangeSpeed * Time.deltaTime);
            
            return;
        }

        Vector3 dirToTarget = (_target.position - _headTr.position).normalized;

        float horizontalDistance = Mathf.Sqrt(dirToTarget.x * dirToTarget.x + dirToTarget.z * dirToTarget.z);
        float verticalDistance = dirToTarget.y;

        float verticalAngle = Mathf.Atan2(verticalDistance, horizontalDistance) * Mathf.Rad2Deg;


        Vector3 correctedForward = Quaternion.Euler(_correctionAngle) * _headTr.forward;
        float horizontalAngle = Vector3.SignedAngle(Vector3.ProjectOnPlane(correctedForward, Vector3.up),
                                                    Vector3.ProjectOnPlane(dirToTarget, Vector3.up),
                                                    Vector3.up);

        bool isWithinVerticalLimit = _minVerticalAngle <= verticalAngle && verticalAngle <= _maxVerticalAngle;
        bool isWithinHorizontalLimit = _minHorizontalAngle <= horizontalAngle && horizontalAngle <= _maxHorizontalAngle;

        _headConstraint.weight = (isWithinVerticalLimit && isWithinHorizontalLimit)
            ? Mathf.MoveTowards(_headConstraint.weight, 1f, _weightChangeSpeed * Time.deltaTime)
            : Mathf.MoveTowards(_headConstraint.weight, 0f, _weightChangeSpeed * Time.deltaTime);
    }

    public void SetEnabled(bool isEnabled)
    {
        _isEnabled = isEnabled;
        Debug.Log(gameObject.name + _isEnabled);
    }

    public void SetTarget(Transform target)
    {
        if (_target == target)
            return;

        _target = target;
        WeightedTransformArray sourceObjs = new WeightedTransformArray{ new WeightedTransform(target, 1) };
        _headConstraint.data.sourceObjects = sourceObjs;

        _rigBuilder.Build();
    }

    private void OnDrawGizmos()
    {
        if (!_gizmosEnabled)
            return;

        if (_headTr == null || _target == null)
            return;

        Quaternion correctionRotation = Quaternion.Euler(_correctionAngle);
        Vector3 correctedForward = correctionRotation * _headTr.forward;
        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(_headTr.position, _headTr.position + correctedForward * 10);   // 원래 방향

    }

}

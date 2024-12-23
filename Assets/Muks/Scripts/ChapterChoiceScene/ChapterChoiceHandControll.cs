using Oculus.Platform;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChapterChoiceHandControll : MonoBehaviour
{
    [SerializeField] private AudioSource _audioSource;
    [SerializeField] private Transform _rayStartTr;
    [SerializeField] private float _rayLength = 10f; // 레이 길이
    [SerializeField] private LayerMask _rayLayerMask; // 충돌할 레이어


    private LineRenderer _lineRenderer;
    private List<IChapterChoiceSceneIInteractive> _interactiveList = new List<IChapterChoiceSceneIInteractive>();
    private RaycastHit _hit;
    private Transform _tmpTr;

    public void InputInteractive()
    {
        if (_interactiveList.Count <= 0)
            return;

        for (int i = 0; i < _interactiveList.Count; ++i)
        {
            _interactiveList[i].Interact();
            _interactiveList[i].Disabled();
            _interactiveList.RemoveAt(i);
            i--;
        }
    }

    public void PlayAudio(AudioClip clip)
    {
        _audioSource.PlayOneShot(clip);
    }


    private void Start()
    {
        _lineRenderer = gameObject.AddComponent<LineRenderer>();
        _lineRenderer.startWidth = 0.01f; // 시작 부분 두께
        _lineRenderer.endWidth = 0.01f;   // 끝 부분 두께
        _lineRenderer.material = new Material(Shader.Find("Unlit/Color"));
        _lineRenderer.material.color = Color.red; // 레이 색상
        _lineRenderer.positionCount = 2; // 선의 시작과 끝
    }

    private void OnEnable()
    {
        if (_lineRenderer == null)
            return;


        _lineRenderer.enabled = true;
        Ray ray = new Ray(_rayStartTr.position, _rayStartTr.forward);
        UpdateLineRenderer(ray);
    }


    private void OnDisable()
    {
        if(_lineRenderer != null)
            _lineRenderer.enabled = false;

        if (_interactiveList.Count <= 0)
            return;

        //아닐경우 비활성화 함수를 실행후 null로 변경
        for (int i = 0, cnt = _interactiveList.Count; i < cnt; ++i)
        {
            _interactiveList[i].Disabled();
        }
        _interactiveList.Clear();
    }

    private void Update()
    {
        Ray ray = new Ray(_rayStartTr.position, _rayStartTr.forward);
        UpdateLineRenderer(ray);
        CheckInteractive(ray);
    }

    private void UpdateLineRenderer(Ray ray)
    {
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit, _rayLength, _rayLayerMask))
        {
            // 충돌이 있으면 레이 끝을 충돌 지점으로 설정
            _lineRenderer.SetPosition(0, _rayStartTr.position); // 레이 시작점
            _lineRenderer.SetPosition(1, hit.point);           // 충돌 지점
        }
        else
        {
            // 충돌이 없으면 레이 끝을 지정된 길이만큼 앞으로 설정
            _lineRenderer.SetPosition(0, _rayStartTr.position); // 레이 시작점
            _lineRenderer.SetPosition(1, _rayStartTr.position + _rayStartTr.forward * _rayLength); // 레이 끝
        }
    }


    /// <summary> Ray를 쏴 상호작용이 가능한 물체를 감지하는 함수 </summary>
    private void CheckInteractive(Ray ray)
    {


        // 카메라 앞으로 레이를 쏜다.
        //만약 hit된 오브젝트가 없을 경우
        if (!Physics.Raycast(ray, out _hit, _rayLength, _rayLayerMask))
        {
            //리스트의 크기가 0일 경우 리턴
            if (_interactiveList.Count <= 0)
                return;

            //아닐경우 비활성화 함수를 실행후 null로 변경
            for (int i = 0, cnt = _interactiveList.Count; i < cnt; ++i)
            {
                _interactiveList[i].Disabled();
            }
            _interactiveList.Clear();
            return;
        }

        IChapterChoiceSceneIInteractive[] tmpIinteractive = _hit.transform.GetComponents<IChapterChoiceSceneIInteractive>();

        if (tmpIinteractive == null && tmpIinteractive.Length < 0)
        {
            for (int i = 0, cnt = _interactiveList.Count; i < cnt; ++i)
            {
                _interactiveList[i].Disabled();
            }
            _interactiveList.Clear();
            return;
        }

        if(_tmpTr != _hit.transform)
        {
            for (int i = 0, cnt = _interactiveList.Count; i < cnt; ++i)
            {
                _interactiveList[i].Disabled();
            }
            _interactiveList.Clear();
        }


        //해당 오브젝트에서 Iinteractive 인터페이스를 참조후 활성화 함수 실행
        for (int i = 0, cnt = tmpIinteractive.Length; i < cnt; ++i)
        {
            if (!_interactiveList.Contains(tmpIinteractive[i]))
            {
                tmpIinteractive[i].Enabled();
                _interactiveList.Add(tmpIinteractive[i]);
                continue;
            }
        }

        _tmpTr = _hit.transform;
    }
}

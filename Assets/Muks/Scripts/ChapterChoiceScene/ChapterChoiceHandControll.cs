using Oculus.Platform;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChapterChoiceHandControll : MonoBehaviour
{
    [SerializeField] private AudioSource _audioSource;
    [SerializeField] private Transform _rayStartTr;
    [SerializeField] private float _rayLength = 10f; // ���� ����
    [SerializeField] private LayerMask _rayLayerMask; // �浹�� ���̾�


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
        _lineRenderer.startWidth = 0.01f; // ���� �κ� �β�
        _lineRenderer.endWidth = 0.01f;   // �� �κ� �β�
        _lineRenderer.material = new Material(Shader.Find("Unlit/Color"));
        _lineRenderer.material.color = Color.red; // ���� ����
        _lineRenderer.positionCount = 2; // ���� ���۰� ��
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

        //�ƴҰ�� ��Ȱ��ȭ �Լ��� ������ null�� ����
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
            // �浹�� ������ ���� ���� �浹 �������� ����
            _lineRenderer.SetPosition(0, _rayStartTr.position); // ���� ������
            _lineRenderer.SetPosition(1, hit.point);           // �浹 ����
        }
        else
        {
            // �浹�� ������ ���� ���� ������ ���̸�ŭ ������ ����
            _lineRenderer.SetPosition(0, _rayStartTr.position); // ���� ������
            _lineRenderer.SetPosition(1, _rayStartTr.position + _rayStartTr.forward * _rayLength); // ���� ��
        }
    }


    /// <summary> Ray�� �� ��ȣ�ۿ��� ������ ��ü�� �����ϴ� �Լ� </summary>
    private void CheckInteractive(Ray ray)
    {


        // ī�޶� ������ ���̸� ���.
        //���� hit�� ������Ʈ�� ���� ���
        if (!Physics.Raycast(ray, out _hit, _rayLength, _rayLayerMask))
        {
            //����Ʈ�� ũ�Ⱑ 0�� ��� ����
            if (_interactiveList.Count <= 0)
                return;

            //�ƴҰ�� ��Ȱ��ȭ �Լ��� ������ null�� ����
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


        //�ش� ������Ʈ���� Iinteractive �������̽��� ������ Ȱ��ȭ �Լ� ����
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

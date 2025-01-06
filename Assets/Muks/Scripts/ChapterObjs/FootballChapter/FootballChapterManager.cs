using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class FootballChapterManager : MonoBehaviour, IChapterObject
{
    [SerializeField] private OVRCameraRig _cameraRig;
    [SerializeField] private Canvas _canvas;
    [SerializeField] private TextMeshProUGUI _scoreText;
    [SerializeField] private TextMeshProUGUI _targetText;
    [SerializeField] private AudioSource _audioSource;
    [SerializeField] private ParticleSystem _touchParticle;
    [SerializeField] private FootballHand _leftHand;
    [SerializeField] private FootballHand _rightHand;

    [Space]
    [SerializeField] private AudioClip _touchSound;


    private GameColorType _targetType;
    private int _score;

    public void Enabled(ChapterManager manager)
    {
        _score = 0;
        _scoreText.text = "Score: 0";
        _canvas.transform.position = _cameraRig.centerEyeAnchor.transform.position + _cameraRig.centerEyeAnchor.transform.forward * 2;
        SetRandomTarget();
        _touchParticle.Stop();

        _leftHand.OnTriggerEnterHandler += OnHandTriggerEnterEvnet;
        _rightHand.OnTriggerEnterHandler += OnHandTriggerEnterEvnet;
    }


    public void Disabled(ChapterManager manager)
    {

        _leftHand.RemoveAllTriggerEnterEvent();
        _rightHand.RemoveAllTriggerEnterEvent();
    }


    public void SetRandomTarget()
    {
        _targetType = (GameColorType)Random.Range(0, (int)GameColorType.Length);
        _targetText.text = "Target: ";

        switch(_targetType)
        {
            case GameColorType.Red:
                _targetText.text += Utility.SetStringColor("Red", Color.red);
                break;

            case GameColorType.Yellow:
                _targetText.text += Utility.SetStringColor("Yellow", Color.yellow);
                break;

            case GameColorType.White:
                _targetText.text += Utility.SetStringColor("White", Color.white);
                break;

            case GameColorType.Black:
                _targetText.text += Utility.SetStringColor("Black", Color.black);
                break;

            case GameColorType.Purple:
                _targetText.text += Utility.SetStringColor("Purple", Color.magenta);
                break;
        }

    }


    private void OnHandTriggerEnterEvnet(FootballPlayer footballPlayer)
    {
        if (footballPlayer.Type != _targetType)
            return;

        _score++;
        _scoreText.text = "Score: " + _score;
        _touchParticle.transform.position = footballPlayer.transform.position + new Vector3(0, 0.2f, 0);
        _touchParticle.Emit(50);
        SetRandomTarget();
        _audioSource.PlayOneShot(_touchSound);
        footballPlayer.ResetPos();
    }


    private void FixedUpdate()
    {
        // ��ǥ ��ġ ���� (ī�޶� ���� + Y�� ������ �߰� ����)
        Vector3 targetPosition = _cameraRig.centerEyeAnchor.transform.position +
                                 _cameraRig.centerEyeAnchor.transform.forward * 2;

        // ��ġ�� �ε巴�� ������� �ϱ�
        _canvas.transform.position = Vector3.Lerp(
            _canvas.transform.position,
            targetPosition,
            Time.deltaTime * 5f); // �������� �̵� �ӵ� ���� (5f�� �ӵ�)

        // ĵ������ ī�޶� �ٶ󺸰� �ϱ�
        Quaternion targetRotation = Quaternion.LookRotation(
            _canvas.transform.position - _cameraRig.centerEyeAnchor.transform.position);

        // ȸ���� �ε巴�� ����
        _canvas.transform.rotation = Quaternion.Lerp(
            _canvas.transform.rotation,
            targetRotation,
            Time.deltaTime * 8f); // �������� ȸ�� �ӵ� ����
    }
}

using Oculus.Interaction;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;

public class FireExtinguisher : MonoBehaviour
{
    [SerializeField] private ParticleSystem _smokeEffect;
    [SerializeField] private GameObject _hitTrigger;
    [SerializeField] private AudioSource _audio;
    [SerializeField] private Animator _animator;
    private bool _wasTriggerPressed;


    private Fire _fire;

    private void Start()
    {
        _smokeEffect.Stop();
        _hitTrigger.gameObject.SetActive(false);
        _audio.Stop();
        _animator.SetBool("Press", false);
    }


    private void OnEnable()
    {
        _smokeEffect.Stop();
        _hitTrigger.gameObject.SetActive(false);
        _audio.Stop();

        _wasTriggerPressed = false;
        _animator.SetBool("Press", false);
        _fire = null;
    }



    private void Update()
    {
        bool isTriggerPressed = IsTriggerPressed();
        if(isTriggerPressed && !_wasTriggerPressed)
        {
            _smokeEffect.Play();
            _hitTrigger.gameObject.SetActive(true);
            _audio.Play();
            _animator.SetBool("Press", true);
        }

        else if(!isTriggerPressed && _wasTriggerPressed)
        {
            _smokeEffect.Stop();
            _hitTrigger.gameObject.SetActive(false);
            _audio.Stop();
            _animator.SetBool("Press", false);
            _fire = null;
        }
        _wasTriggerPressed = isTriggerPressed;
    }


    private void FixedUpdate()
    {
        _fire?.PutOutTheFire(Time.deltaTime);
    }


    private bool IsTriggerPressed()
    {
        InputDevice rightHand = InputDevices.GetDeviceAtXRNode(XRNode.RightHand);
        if (rightHand.TryGetFeatureValue(CommonUsages.triggerButton, out bool isPressed))
            return isPressed;

        return false;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.GetComponent<Fire>() == null)
        {
            Debug.LogError(other.name + "은 Fire 클래스를 가지고 있지 않습니다.");
            return;
        }

        _fire = other.GetComponent<Fire>();
    }


    private void OnTriggerExit(Collider other)
    {
        if (_fire == null)
            return;

        if (_fire.gameObject != other.gameObject)
            return;

        _fire = null;
    }
}

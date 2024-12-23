using UnityEngine;
using UnityEngine.UI;

public class FadeCanvas : MonoBehaviour
{
    [SerializeField] private Image _fadeImage;
    public Image FadeImage => _fadeImage;


    private void Update()
    {
        transform.position = Camera.main.transform.position + Camera.main.transform.forward * 0.5f;
        transform.rotation = Quaternion.LookRotation(transform.position - Camera.main.transform.position);
    }
}

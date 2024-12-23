using System.Collections.Generic;
using UnityEngine;

public class OutLineController : MonoBehaviour
{
    public KeyCode InputKey => KeyCode.None;

    [SerializeField] private Renderer[] _activeRenderers;
    [SerializeField] private float _outlineThickness;
    private Material _outLineMaterial;

    private List<Material> _activeMaterials = new List<Material>();
    private void Awake()
    {
        _outLineMaterial = Resources.Load<Material>("Materials/OutLineMaterial");
        _activeMaterials.Clear();
        for(int i = 0, cnt = _activeRenderers.Length; i < cnt; ++i)
        {
            Material material = new Material(_outLineMaterial);
            _activeMaterials.Add(material);

            Material[] originalMaterials = _activeRenderers[i].materials;
            Material[] newMaterials = new Material[originalMaterials.Length + 1];
            originalMaterials.CopyTo(newMaterials, 0);
            newMaterials[originalMaterials.Length] = material;

            _activeRenderers[i].materials = newMaterials;
            material.SetFloat("_OutlineEnabled", 0);
            material.SetFloat("_OutlineThickness", _outlineThickness);
        }
    }

    public void DisableInteraction()
    {
        if(_activeMaterials.Count <= 0)
            Awake();

        for (int i = 0, cnt = _activeMaterials.Count; i < cnt; ++i)
        {
            _activeMaterials[i].SetFloat("_OutlineEnabled", 0);
        }
    }

    public void EnableInteraction()
    {
        if (_activeMaterials.Count <= 0)
            Awake();

        for (int i = 0, cnt = _activeMaterials.Count; i < cnt; ++i)
        {
            _activeMaterials[i].SetFloat("_OutlineEnabled", 1);
        }
    }

    public void Interact()
    {
        Debug.Log("½ÇÇà");
    }

}

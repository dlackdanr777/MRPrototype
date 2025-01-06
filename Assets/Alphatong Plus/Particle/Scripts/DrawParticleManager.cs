using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawParticleManager : MonoBehaviour
{
    [System.Serializable]
    private struct ParticleInfo
    {
        public string gParticleName;
        public GameObject gPrefab;        
        public float gDuration;
    }

    // Start is called before the first frame update
    [SerializeField]
    private List<ParticleInfo> Particles;
    private Dictionary<string, ParticleInfo> ParticlesDic = new Dictionary<string, ParticleInfo>();

    private static DrawParticleManager instance;
    public static DrawParticleManager ginstance => instance;


    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }

    }
    private void Start()
    {
        foreach (var item in Particles)
        {
            ParticlesDic.Add(item.gParticleName ,item);
        }
    } 

    public GameObject GenerateParticle(Vector3 _Pos, string _ParticleName , Transform Parent = null)
    {
        if (!ParticlesDic.ContainsKey(_ParticleName)) return null;
        var mParticle = ParticlesDic[_ParticleName];
        var mItem = Instantiate(mParticle.gPrefab, _Pos, Quaternion.identity, Parent);
        Destroy(mItem, mParticle.gDuration);
        return mItem;
    }

    public GameObject GenerateParticle(Vector3 _Pos, Quaternion rot, string _ParticleName, Transform Parent = null)
    {
        if (!ParticlesDic.ContainsKey(_ParticleName)) return null;
        var mParticle = ParticlesDic[_ParticleName];
        var mItem = Instantiate(mParticle.gPrefab, _Pos, rot, Parent);
        Destroy(mItem, mParticle.gDuration);
        return mItem;
    }
}

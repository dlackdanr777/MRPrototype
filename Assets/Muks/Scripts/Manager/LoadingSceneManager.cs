using Muks.Tween;
using System;
using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;



public class LoadingSceneManager : MonoBehaviour
{
    public static event Action OnLoadSceneHandler;

    [Tooltip("로딩이 최소 몇 초가 걸리게 할지 설정")]
    [SerializeField] private float _changeSceneTime = 1;

    private static string _nextScene;
    private static bool IsLoaded = false;

    private void Start()
    {
        GC.Collect();
        IsLoaded = true;
        StartCoroutine(LoadScene());
    }


    public static void LoadScene(string sceneName)
    {
        if (IsLoaded)
        {
            Debug.Log("이미 로드중임");
            return;
        }

        _nextScene = sceneName;
        IsLoaded = true;
        SceneManager.LoadScene("LoadingScene");
        OnLoadSceneHandler?.Invoke();
    }


    private IEnumerator LoadScene()
    {
        AsyncOperation op = SceneManager.LoadSceneAsync(_nextScene);
        op.allowSceneActivation = false;
        float timer = 0f;
        IsLoaded = false;
        while (!op.isDone)
        {
            yield return null;
            if (0.9f <= op.progress)
            {
                timer += Time.deltaTime;
                if (_changeSceneTime < timer)
                {
                    op.allowSceneActivation = true;
                    IsLoaded = false;
                    yield break;
                }
            }
        }

        
    }
}

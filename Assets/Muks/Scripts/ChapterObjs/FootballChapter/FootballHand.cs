using System;
using UnityEngine;

public class FootballHand : MonoBehaviour, IChapterObject
{
    public event Action<FootballPlayer> OnTriggerEnterHandler;

    public void Enabled(ChapterManager manager)
    {
    }

    public void Disabled(ChapterManager manager)
    {
    }


    public void RemoveAllTriggerEnterEvent()
    {
        OnTriggerEnterHandler = null;
    }


    private void OnTriggerEnter(Collider other)
    {
        if (!other.TryGetComponent(out FootballPlayer footballPlayer))
            return;

        OnTriggerEnterHandler?.Invoke(footballPlayer);
    }
}

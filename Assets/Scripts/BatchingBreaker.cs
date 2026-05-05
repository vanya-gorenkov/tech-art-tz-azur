using UnityEngine;

public class BatchingBreaker : MonoBehaviour
{
    private void Awake()
    {
        BreakSpriteRenderers();
        BreakParticleSystems();
    }

    private void BreakSpriteRenderers()
    {
        var renderers = FindObjectsOfType<SpriteRenderer>(true);

        foreach (var r in renderers)
        {
            if (r.sharedMaterial == null)
            {
                continue;
            }

            r.material = new Material(r.sharedMaterial);
        }
    }

    private void BreakParticleSystems()
    {
        var psRenderers = FindObjectsOfType<ParticleSystemRenderer>(true);

        foreach (var r in psRenderers)
        {
            if (r.sharedMaterial == null)
            {
                continue;
            }

            r.material = new Material(r.sharedMaterial);
        }
    }
}
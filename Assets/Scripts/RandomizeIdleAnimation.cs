using UnityEngine;

public class RandomizeIdleAnimation : MonoBehaviour
{
    [SerializeField]
    private string animationStateName = "Idle";
    [SerializeField]
    private Animator animator;

    private void Start()
    {
        if (animator == null) return;

        animator.Play(animationStateName, 0, Random.value);
    }
}
using UnityEngine;

public class ToggleObjects : MonoBehaviour
{
    [SerializeField]
    private GameObject[] objectsToToggle;

    private bool isActive = true;

    public void Toggle()
    {
        isActive = !isActive;

        foreach (var obj in objectsToToggle)
        {
            if (obj != null)
            {
                obj.SetActive(isActive);
            }
        }
    }
}
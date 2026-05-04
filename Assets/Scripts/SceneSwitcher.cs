using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneSwitcher : MonoBehaviour
{
    [SerializeField]
    private string sceneA;
    [SerializeField]
    private string sceneB;

    public void SwitchScene()
    {
        var currentScene = SceneManager.GetActiveScene().name;

        if (currentScene == sceneA)
        {
            SceneManager.LoadScene(sceneB);
        }
        else if (currentScene == sceneB)
        {
            SceneManager.LoadScene(sceneA);
        }
    }
}
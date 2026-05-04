using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneSwitcher : MonoBehaviour
{
    [SerializeField]
    private string sceneA;
    [SerializeField]
    private string sceneB;

    [SerializeField]
    private KeyCode switchKey = KeyCode.Space;

    private void Update()
    {
        if (Input.GetKeyDown(switchKey))
        {
            SwitchScene();
        }
    }

    private void SwitchScene()
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
using UnityEngine;
using TMPro;

public class FPSCounter : MonoBehaviour
{
    [SerializeField]
    private TMP_Text fpsText;
    private float _deltaTime = 0.0f;

    private void Update()
    {
        _deltaTime += (Time.unscaledDeltaTime - _deltaTime) * 0.1f;

        var fps = 1.0f / _deltaTime;
        fpsText.text = "FPS: " + Mathf.Ceil(fps).ToString();
    }
}
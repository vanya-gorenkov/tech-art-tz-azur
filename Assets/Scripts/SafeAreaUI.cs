using UnityEngine;

public class SafeAreaUI : MonoBehaviour
{
    [SerializeField]
    private RectTransform panel;

    [SerializeField]
    private float topMargin;
    [SerializeField]
    private float bottomMargin;
    [SerializeField]
    private float leftMargin;
    [SerializeField]
    private float rightMargin;

    private void Start()
    {
        ApplySafeArea();
    }

    private void ApplySafeArea()
    {
        var top = Screen.height * topMargin;
        var bottom = Screen.height * bottomMargin;
        var left = Screen.width * leftMargin;
        var right = Screen.width * rightMargin;

        panel.offsetMin = new Vector2(left, bottom);
        panel.offsetMax = new Vector2(-right, -top);
    }
}
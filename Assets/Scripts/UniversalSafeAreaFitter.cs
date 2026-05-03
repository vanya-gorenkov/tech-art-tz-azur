using UnityEngine;

[RequireComponent(typeof(RectTransform))]
public class UniversalSafeAreaFitter : MonoBehaviour
{
    private enum Mode
    {
        Auto,
        VerticalOnly,
        HorizontalOnly,
        Both
    }

    [SerializeField]
    private Mode mode = Mode.Auto;

    [SerializeField]
    private Vector4 additionalPadding = Vector4.zero;

    [SerializeField]
    private bool scaleWithCanvas = true;

    private RectTransform _rectTransform;
    private Rect _lastSafeArea;
    private ScreenOrientation _lastOrientation;
    private Canvas _parentCanvas;

    private void Awake()
    {
        _rectTransform = GetComponent<RectTransform>();

        _rectTransform.anchorMin = Vector2.zero;
        _rectTransform.anchorMax = Vector2.one;
        _rectTransform.pivot = new Vector2(0.5f, 0.5f);

        _parentCanvas = GetComponentInParent<Canvas>();
        ApplySafeArea();
    }

    private void Update()
    {
        if (Screen.safeArea != _lastSafeArea || Screen.orientation != _lastOrientation)
        {
            ApplySafeArea();
        }
    }

    private void ApplySafeArea()
    {
        var safeArea = Screen.safeArea;
        _lastSafeArea = safeArea;
        _lastOrientation = Screen.orientation;

        var left = safeArea.xMin;
        var bottom = safeArea.yMin;
        var right = Screen.width - safeArea.xMax;
        var top = Screen.height - safeArea.yMax;

        left += additionalPadding.x;
        top += additionalPadding.y;
        right += additionalPadding.z;
        bottom += additionalPadding.w;

        var scale = 1f;
        if (scaleWithCanvas && _parentCanvas != null)
        {
            scale = _parentCanvas.scaleFactor;
            if (scale <= 0)
            {
                scale = 1f;
            }
        }

        left /= scale;
        right /= scale;
        top /= scale;
        bottom /= scale;

        var applyVertical = mode == Mode.Both || mode == Mode.VerticalOnly ||
                            mode == Mode.Auto && Screen.height > Screen.width;
        var applyHorizontal = mode == Mode.Both || mode == Mode.HorizontalOnly ||
                              mode == Mode.Auto && Screen.width > Screen.height;

        var offsetMin = _rectTransform.offsetMin;
        var offsetMax = _rectTransform.offsetMax;

        offsetMin.x = applyHorizontal ? left : 0f;
        offsetMin.y = applyVertical ? bottom : 0f;

        offsetMax.x = applyHorizontal ? -right : 0f;
        offsetMax.y = applyVertical ? -top : 0f;

        _rectTransform.offsetMin = offsetMin;
        _rectTransform.offsetMax = offsetMax;
    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        if (!Application.isPlaying && _rectTransform == null)
        {
            _rectTransform = GetComponent<RectTransform>();
            if (_rectTransform != null)
            {
                _rectTransform.anchorMin = Vector2.zero;
                _rectTransform.anchorMax = Vector2.one;
                _rectTransform.pivot = new Vector2(0.5f, 0.5f);
            }
        }
    }
#endif
}
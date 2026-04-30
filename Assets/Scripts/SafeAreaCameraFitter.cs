using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(Camera))]
public class SafeAreaCameraFitter : MonoBehaviour
{
    [SerializeField]
    private float visibleWidth = 9f;
    [SerializeField]
    private float visibleHeight = 16f;

    [SerializeField]
    private bool drawGizmos = true;

    [SerializeField]
    private Camera camera;

    private int _lastScreenWidth;
    private int _lastScreenHeight;

    private void OnEnable()
    {
        if (camera == null)
        {
            camera = GetComponent<Camera>();
        }
        Apply();
    }

    private void Update()
    {
#if UNITY_EDITOR
        Apply();
#else
        if (Screen.width != _lastScreenWidth || Screen.height != _lastScreenHeight)
        {
            Apply();
        }
#endif
    }

    private void Apply()
    {
        if (camera == null)
        {
            camera = GetComponent<Camera>();
        }
        if (!camera.orthographic)
        {
            return;
        }

        _lastScreenWidth = Screen.width;
        _lastScreenHeight = Screen.height;

        var aspect = (float)_lastScreenWidth / _lastScreenHeight;

        var sizeByHeight = visibleHeight / 2f;
        var sizeByWidth = visibleWidth / 2f / aspect;

        var targetSize = Mathf.Max(sizeByHeight, sizeByWidth);

        if (!Mathf.Approximately(camera.orthographicSize, targetSize))
        {
            camera.orthographicSize = targetSize;
        }
    }

#if UNITY_EDITOR
    private void OnValidate() => Apply();
#endif

    private void OnDrawGizmos()
    {
        if (!drawGizmos)
        {
            return;
        }

        var center = transform.position;

        var halfW = visibleWidth * 0.5f;
        var halfH = visibleHeight * 0.5f;

        var bl = new Vector3(center.x - halfW, center.y - halfH, 0);
        var br = new Vector3(center.x + halfW, center.y - halfH, 0);
        var tr = new Vector3(center.x + halfW, center.y + halfH, 0);
        var tl = new Vector3(center.x - halfW, center.y + halfH, 0);

        Gizmos.color = Color.green;

        Gizmos.DrawLine(bl, br);
        Gizmos.DrawLine(br, tr);
        Gizmos.DrawLine(tr, tl);
        Gizmos.DrawLine(tl, bl);
    }
}
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteAlways]
[RequireComponent(typeof(SortingGroup))]
public class IsoSortHelper : MonoBehaviour
{
    [SerializeField]
    private Vector2 pivot = Vector2.zero;
    [SerializeField]
    private float height = 0f;

    [SerializeField]
    private bool syncZ = true;

    private float _zStep = 0.01f;

    private SortingGroup _sortingGroup;

    private void OnEnable()
    {
        _sortingGroup = GetComponent<SortingGroup>();
        UpdateSorting();
    }

    private void OnValidate()
    {
        _sortingGroup = GetComponent<SortingGroup>();
        UpdateSorting();
    }

    private void Update()
    {
        /*if (Application.isPlaying)
        {
            return;
        }*/

        UpdateSorting();
    }

    private void UpdateSorting()
    {
        if (_sortingGroup == null)
        {
            return;
        }

        var fullOffset = GetFullOffset();

        var order = Mathf.RoundToInt(-fullOffset.y * 100f);
        _sortingGroup.sortingOrder = order;

        if (syncZ)
        {
            var pos = transform.position;
            pos.z = -order * _zStep;
            transform.position = pos;
        }
    }

    private Vector3 GetFullOffset() => transform.position + (Vector3)pivot + Vector3.up * -height;

    private void OnDrawGizmos()
    {
        var fullOffset = GetFullOffset();

        Gizmos.color = Color.cyan;
        Gizmos.DrawSphere(fullOffset, 0.1f);

        Gizmos.color = Color.blue;
        Gizmos.DrawLine(transform.position + (Vector3)pivot, fullOffset);
    }
}
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BezierPointer : MonoBehaviour
{
    public Transform startPoint;
    public Transform endPoint;
    public Transform controlPoint;
    public float duration = 1.0f;
    private LineRenderer lineRenderer;

    void Start()
    {
       // lineRenderer = GetComponent<LineRenderer>();
       // lineRenderer.positionCount = 100; // 增加点的数量来绘制曲线
    }

    void Update()
    {
        //DrawBezierCurve();
        // 可添加其他控制光标的逻辑
    }

    void DrawBezierCurve()
    {
        for (int i = 0; i <= 100; i++)
        {
            float t = i / 100f;
            Vector3 point = Mathf.Pow(1 - t, 2) * startPoint.position +
                            2 * (1 - t) * t * controlPoint.position +
                            Mathf.Pow(t, 2) * endPoint.position;
            lineRenderer.SetPosition(i, point);
        }
    }
    public Vector3 GetEndPoint()
    {
        return endPoint.position;
    }
}

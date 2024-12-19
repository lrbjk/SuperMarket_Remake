using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightControl : MonoBehaviour
{

    public Light directionalLight; // 引用场景中的方向光
    public float rotationAngle = 0f; // 旋转角度，0-360度

    void Update()
    {
        // 确保角度在0-360度之间
        rotationAngle = Mathf.Repeat(rotationAngle, 360f);

        // 计算方向光的方向
        Vector3 lightDirection = Quaternion.AngleAxis(rotationAngle, Vector3.forward) * new Vector3(-1,0,0);

        // 设置方向光的方向（注意方向光是无限远的，所以我们只能设置它的方向）
        directionalLight.transform.forward = lightDirection;

        // 根据角度设置阴影投射
        directionalLight.shadows = rotationAngle <= 180f ? LightShadows.Soft : LightShadows.None;
    }
}
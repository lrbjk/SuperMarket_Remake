using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Transport : MonoBehaviour
{
    public GameObject player; // 玩家角色
    public BezierPointer bezierPointer;

    private void Update()
    {
        if (Input.GetButtonDown("Fire1")) // 用于检测传送的按钮
        {
            Vector3 targetPosition = bezierPointer.GetEndPoint(); // 通过光标获取目标位置
            TeleportPlayer(targetPosition);
        }
    }

    private void TeleportPlayer(Vector3 targetPosition)
    {
        player.transform.position = new Vector3(targetPosition.x, player.transform.position.y, targetPosition.z); // 传送玩家
    }
}

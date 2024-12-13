
using UnityEngine;

public class Transport : MonoBehaviour
{
    public GameObject player; // 玩家角色
    public BezierPointer bezierPointer;
    private float lastClickTime = 0f;
    private float doubleClickTimeThreshold = 0.5f; // 双击时间间隔阈值

    private void Update()
    {
        if (Input.GetButtonDown("Fire1")) // 检测传送按钮按下
        {
            float timeSinceLastClick = Time.time - lastClickTime;

            if (timeSinceLastClick <= doubleClickTimeThreshold)
            {
                // 如果两次点击之间的时间小于阈值，则认为是双击
                Vector3 targetPosition = bezierPointer.GetEndPoint(); // 通过光标获取目标位置
                TeleportPlayer(targetPosition);
            }

            // 更新上一次点击时间
            lastClickTime = Time.time;
        }
    }

    private void TeleportPlayer(Vector3 targetPosition)
    {
        player.transform.position = new Vector3(targetPosition.x, player.transform.position.y, targetPosition.z); // 传送玩家
    }
}

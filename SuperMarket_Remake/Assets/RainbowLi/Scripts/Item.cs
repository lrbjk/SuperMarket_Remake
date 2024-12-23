using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Item : MonoBehaviour
{
    public Transform player;
    void Awake()
    {
        player = GameObject.FindGameObjectWithTag("Player").transform.Find("Main Camera").Find("PickUpPoint").transform;
    }
    public void PickUp()
    {
        transform.GetComponent<Rigidbody>().isKinematic = true;
        transform.SetParent(player);
        transform.localPosition = Vector3.zero;
    }
    public void Release()
    {
        transform.GetComponent<Rigidbody>().isKinematic = false;
        transform.SetParent(null);
    }
}

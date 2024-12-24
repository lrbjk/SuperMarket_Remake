using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomerMov : MonoBehaviour
{
    [Header("步进距离")]
    public float movDis;

    [Header("步进指令")]
    public string[] movIns;

    private int lastIns;

    [Header("步进间隔时间")]
    public float movTime;
    private float _movTime;

    private int nowIndex;

    public bool canMove;

    void Start()
    {
        nowIndex = 0;
        lastIns = -1;
        _movTime = movTime;
        canMove = true;
    }

    void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Customer"){
            canMove = false;
        }
    }

    void OnTriggerExit(Collider other)
    {
        if(other.gameObject.tag == "Customer"){
            canMove = true;
        }
    }

    void Update()
    {
        if(nowIndex < movIns.Length){
            if(movTime <= 0){
                if(canMove){
                    Move();
                    movTime = _movTime;
                }
            }else{
                movTime -= Time.fixedDeltaTime;
            }
        }
    }

    void Move(){
        switch(movIns[nowIndex]){
            case "A": {if(lastIns!=0){transform.localRotation = Quaternion.Euler(0, 90, 0);}transform.position = new Vector3(transform.position.x + movDis, transform.position.y, transform.position.z);lastIns = 0;}break;
            case "D": {if(lastIns!=1){transform.localRotation = Quaternion.Euler(0, 90, 0);}transform.position = new Vector3(transform.position.x - movDis, transform.position.y, transform.position.z);lastIns = 1;}break;
            case "S": {if(lastIns!=2){transform.localRotation = Quaternion.Euler(0, 0, 0);}transform.position = new Vector3(transform.position.x, transform.position.y, transform.position.z + movDis);lastIns = 2;}break;
            case "W": {if(lastIns!=2){transform.localRotation = Quaternion.Euler(0, 0, 0);}transform.position = new Vector3(transform.position.x, transform.position.y, transform.position.z - movDis);lastIns = 3;}break;
        }
        nowIndex ++;
    }
}

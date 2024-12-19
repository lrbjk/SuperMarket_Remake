using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomerMov : MonoBehaviour
{
    [Header("步进距离")]
    public float movDis;

    [Header("步进指令")]
    public string[] movIns;

    [Header("步进间隔时间")]
    public float movTime;
    private float _movTime;

    private int nowIndex;

    public bool canMove;

    void Start()
    {
        nowIndex = 0;
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
            case "A": {transform.position = new Vector3(transform.position.x + movDis, transform.position.y, transform.position.z);}break;
            case "D": {transform.position = new Vector3(transform.position.x - movDis, transform.position.y, transform.position.z);}break;
            case "S": {transform.position = new Vector3(transform.position.x, transform.position.y, transform.position.z + movDis);}break;
            case "W": {transform.position = new Vector3(transform.position.x, transform.position.y, transform.position.z - movDis);}break;
        }
        nowIndex ++;
    }
}

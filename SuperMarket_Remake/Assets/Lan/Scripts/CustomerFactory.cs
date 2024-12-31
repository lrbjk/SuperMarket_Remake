using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomerFactory : MonoBehaviour
{
    public GameObject[] gameObjects;

    public float CD;

    public int customerCount;

    private float _CD;

    // Start is called before the first frame update
    void Start()
    {
        _CD = CD;
    }

    // Update is called once per frame
    void Update()
    {
        if(customerCount > 0){
            if(CD >= 0){
                CD -= Time.fixedDeltaTime;
            }else{
                CD = _CD;
                InvokeNewCustomer();
                customerCount --;
            }
        }
    }

    void InvokeNewCustomer(){
        int r = Random.Range(0, gameObjects.Length);
        Instantiate(gameObjects[r], transform.position, Quaternion.identity);
    }
}

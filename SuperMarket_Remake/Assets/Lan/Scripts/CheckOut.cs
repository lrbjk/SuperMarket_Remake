using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CheckOut : MonoBehaviour
{
    public GameObject checkVFX;

    void OnTriggerEnter(Collider other){
        if(other.gameObject.tag == "Customer"){
            float a = other.gameObject.transform.GetChild(1).GetComponent<CustomerPick>().CheckOut();
            Debug.Log(a);
            Destroy(other.gameObject);
            Instantiate(checkVFX, transform.position, Quaternion.identity);
        }
    }
}

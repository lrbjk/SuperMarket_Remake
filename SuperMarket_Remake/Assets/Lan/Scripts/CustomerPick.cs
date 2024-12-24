using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomerPick : MonoBehaviour
{
    private ArrayList arrayList = new ArrayList();

    public string[] toBuy;

    private Collider coll;

    public void updateToBuy(){
        for(int i=0; i<toBuy.Length; i++){
            arrayList.Add(toBuy[i]);
        }
    }

    void Start()
    {
        updateToBuy();
        coll = GetComponent<Collider>();
        Debug.Log("Arraylist:"+arrayList.Contains("Chip"));
    }

    void OnTriggerEnter(Collider other)
    {
        string tag = other.gameObject.tag;
        if(arrayList.Contains(tag)){
            Debug.Log("Get good!");
            other.transform.parent.GetComponent<Animator>().Play("Kill");
            arrayList.Remove(tag);
        }else{
            Debug.Log("This good is not needed!");
        }
    }

    // void OnTriggerStay(Collider other)
    // {
    //     if(arrayList.Contains(other.gameObject.tag)){
    //         Debug.Log("Get good!");
    //         Destroy(other.gameObject);
    //     }else{
    //         Debug.Log("This good is not needed!");
    //     }
    // }
}

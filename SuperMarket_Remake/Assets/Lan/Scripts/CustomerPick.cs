using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomerPick : MonoBehaviour
{
    private ArrayList arrayList;

    public string[] toBuy;

    public int[] toBuyInt;

    public NeedItemUI niu;

    private Collider coll;

    public void updateToBuy(){
        //for(int i=0; i<toBuy.Length; i++){
        //    arrayList.Add(toBuy[i]);
        //}
        arrayList = new ArrayList(toBuy);
    }

    void Start()
    {
        updateToBuy();
        coll = GetComponent<Collider>();
        niu.updateNIU(toBuyInt);
    }

    int returnIndex(string tag){
        for(int i=0; i<arrayList.Count; i++){
            if(arrayList[i].Equals(tag)){
                Debug.Log("Return"+i);
                arrayList[i] = "OHHHH"+arrayList[i];
                return i;
            }
        }
        return -1;
    }

    void OnTriggerEnter(Collider other)
    {
        string tag = other.gameObject.tag;
        if(arrayList.Contains(tag)){
            other.transform.parent.GetComponent<Animator>().Play("Kill");
            niu.changeColor(returnIndex(tag));
            // returnIndex(tag);
            // arrayList.Remove(tag);
        }
    }

    public float CheckOut(){
        return  CustomerNeed.Calculate(arrayList);
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

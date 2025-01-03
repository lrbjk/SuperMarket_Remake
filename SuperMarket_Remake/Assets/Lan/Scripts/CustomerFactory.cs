using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomerFactory : MonoBehaviour
{
    public GameObject[] gameObjects;

    public float CD;

    public string[] userNeed;

    public int customerCount;

    private float _CD;

    // Start is called before the first frame update
    void Start()
    {
        _CD = CD;
        ClearCustomerNeed();
    }

    // Clear the state of customerNeed, because they are static variables.
    void ClearCustomerNeed(){
        CustomerNeed.currentNeed = "";
        CustomerNeed.lastNeed = "";
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
        // Get a random integer between 0 and customer.Length - 1
        int r = Random.Range(0, gameObjects.Length);

        // Update the currentNeed and lastNeed
        // If the customer is not the first customer, update the lastNeed
        if(CustomerNeed.currentNeed != ""){
            CustomerNeed.lastNeed = CustomerNeed.currentNeed;
        }

        // Update the currentNeed
        CustomerNeed.currentNeed = userNeed[r];

        // Generate the customer
        Instantiate(gameObjects[r], transform.position, Quaternion.identity);
    }
}

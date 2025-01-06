using UnityEngine;

public class BuyingButton : MonoBehaviour
{
    public GameObject shopCanvas; 

    void Start()
    {
        if (shopCanvas == null)
        {
            Debug.LogError("ShopCanvas is not assigned in BuyingButton.");
            return;
        }

        
        shopCanvas.SetActive(false);
    }

    public void OnBuyingButtonClick()
    {
        if (shopCanvas != null)
        {
            shopCanvas.SetActive(true); 
        }
        else
        {
            Debug.LogError("ShopCanvas is not assigned.");
        }
    }
}

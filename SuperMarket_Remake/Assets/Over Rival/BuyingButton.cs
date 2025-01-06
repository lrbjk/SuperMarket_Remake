using UnityEngine;

public class BuyingButton : MonoBehaviour
{
    public Canvas shopCanvas; 

    void Start()
    {
        if (shopCanvas == null)
        {
            Debug.LogError("ShopCanvas is not assigned in BuyingButton.");
            return;
        }

        
        shopCanvas.gameObject.SetActive(false);
    }

    public void OnBuyingButtonClick()
    {
        if (shopCanvas != null)
        {
            shopCanvas.gameObject.SetActive(true); 
        }
        else
        {
            Debug.LogError("ShopCanvas is not assigned.");
        }
    }
}

using UnityEngine;
using UnityEngine.UI;

public class ComputerInteraction : MonoBehaviour
{
    public GameObject shopCanvas;
    public Button buyBottleButton;
    public Button buyBookButton;
    public Button buyFoodButton;
    public Button commitButton;
    public Button quitButton;
    public Text cartSummaryText;

    public GameObject drinkPrefab;   
    public GameObject porridgePrefab; 
    public GameObject chipPrefab;    

    private bool isShopOpen = false;
    private int bottleCount = 0;
    private int bookCount = 0;
    private int foodCount = 0;

    void Start()
    {
        //if (shopCanvas == null || buyBottleButton == null || buyBookButton == null || buyFoodButton == null || commitButton == null || quitButton == null || cartSummaryText == null)
        //{
        //    Debug.LogError("One or more UI components are not assigned in ComputerInteraction.");
        //    return;
        //}

        //if (drinkPrefab == null || porridgePrefab == null || chipPrefab == null)
        //{
        //    Debug.LogError("One or more item prefabs are not assigned in ComputerInteraction.");
        //    return;
        //}

        shopCanvas.SetActive(false);

        buyBottleButton.onClick.AddListener(() => AddToCart("bottle"));
        buyBookButton.onClick.AddListener(() => AddToCart("book"));
        buyFoodButton.onClick.AddListener(() => AddToCart("food"));
        commitButton.onClick.AddListener(CommitPurchase);
        quitButton.onClick.AddListener(CloseShop);

        GameManager.InitializeBalanceText(GameObject.Find("BalanceText").GetComponent<Text>());

        UpdateCartSummary();
    }

    void Update()
    {
        if (Input.GetMouseButtonDown(0)) 
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out RaycastHit hit))
            {
                if (hit.transform == transform && !isShopOpen)
                {
                    OpenShop();
                }
            }
        }
    }

    void OpenShop()
    {
        isShopOpen = true;
        shopCanvas.SetActive(true);
        UpdateCartSummary();
    }

    public void CloseShop()
    {
        isShopOpen = false;
        shopCanvas.SetActive(false);
    }

    void AddToCart(string item)
    {
        switch (item)
        {
            case "bottle":
                bottleCount++;
                Debug.Log($"Added a bottle to cart. Total: {bottleCount}");
                break;
            case "book":
                bookCount++;
                Debug.Log($"Added a book to cart. Total: {bookCount}");
                break;
            case "food":
                foodCount++;
                Debug.Log($"Added food to cart. Total: {foodCount}");
                break;
        }
        UpdateCartSummary();
    }

    void CommitPurchase()
    {
        int totalCost = bottleCount + bookCount + foodCount;

        if (GameManager.Balance >= totalCost)
        {
            GameManager.Balance -= totalCost;
            GameManager.UpdateBalanceUI();

            GenerateObjects(bottleCount, drinkPrefab);
            GenerateObjects(bookCount, porridgePrefab);
            GenerateObjects(foodCount, chipPrefab);

            bottleCount = 0;
            bookCount = 0;
            foodCount = 0;

            UpdateCartSummary();
            CloseShop();
        }
        else
        {
            Debug.Log("Not enough balance to complete the purchase.");
        }
    }

    void UpdateCartSummary()
    {
        cartSummaryText.text = $"Cart Summary:\Basketballs: {bottleCount}\nDrinks: {bookCount}\nDices: {foodCount}";
    }

    void GenerateObjects(int count, GameObject prefab)
    {
        if (count <= 0 || prefab == null) return;

        for (int i = 0; i < count; i++)
        {
           
            Vector3 spawnPosition = Camera.main.transform.position + Camera.main.transform.forward * 2 + new Vector3(i * 0.5f, 0, 0); // 间隔排列

       
            Instantiate(prefab, spawnPosition, Quaternion.identity);
        }
    }
}

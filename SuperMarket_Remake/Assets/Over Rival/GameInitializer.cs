using UnityEngine;
using UnityEngine.UI;

public class GameInitializer : MonoBehaviour
{
    public Text balanceText;

    void Start()
    {
        if (balanceText == null)
        {
            Debug.LogError("Balance Text is not assigned in GameInitializer. Please assign it in the Inspector.");
            return;
        }

        GameManager.InitializeBalanceText(balanceText);
    }
}

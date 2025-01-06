using UnityEngine;
using UnityEngine.UI;

public static class GameManager
{
    public static int Balance = 100; 

    private static Text balanceText; 

    public static void InitializeBalanceText(Text textComponent)
    {
        balanceText = textComponent;
        UpdateBalanceUI();
    }

    public static void UpdateBalanceUI()
    {
        if (balanceText != null)
        {
            balanceText.text = $"Balance: {Balance}";
            Debug.Log($"Balance UI updated: {Balance}");
        }
        else
        {
            Debug.LogError("Balance Text is not assigned or initialized.");
        }
    }
}

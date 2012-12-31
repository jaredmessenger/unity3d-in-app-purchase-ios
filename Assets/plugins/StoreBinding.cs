using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class StoreBinding 
{
#if UNITY_IPHONE
	[DllImport("__Internal")]
	private static extern void _initStoreWithProducts(string products);
	
	[DllImport("__Internal")]
	private static extern bool _canMakeStorePurchases();
	
	[DllImport("__Internal")]
	private static extern void _getProductInfo(string itemName);
	
	[DllImport("__Internal")]
	private static extern void _purchaseProduct(string itemName);
	
	[DllImport("__Internal")]
	private static extern void _setVerificationServer(string url);
	
	public static void LoadStore(string[] productArray)
	{
		string products = ArrayToString(productArray);
		
		_initStoreWithProducts(products);

	}

	public static bool CanMakeStorePurchases()
	{
		return _canMakeStorePurchases();	
	}
	
	public static void LoadStoreProductsWithInfo(string[] productArray)
	{
		// Call this only after you receive notification that the store loaded properly
		// 
		foreach(string product in productArray)
		{
			_getProductInfo(product);	
		}
		
	}
	
	public static void SetReceiptVerificationServer(string url)
	{
		Debug.Log("Setting URL to " + url);
		_setVerificationServer(url);
	}
	
	public static void PurchaseProduct(string productName)
	{
		_purchaseProduct(productName);
	}
	
	public static void GetProductInfo(string productName)
	{
		_getProductInfo(productName);
	}
	
	public static string ArrayToString(string[] convertArray)
	{
		string returnString = string.Empty;
		for(int i=0; i<convertArray.Length; i++)
		{
			returnString += convertArray[i];
			if(i != convertArray.Length - 1)
			{
				returnString += "|";	
			}
		}
		
		return returnString;
	}
	
	public static StoreProduct StringToProduct(string productInfo)
	{
		string[] words = productInfo.Split('|');
		if(words.Length == 4)
		{
			StoreProduct product = new StoreProduct(
				words[0],
				words[1],
				words[2],
				words[3]);
			return product;
		}else{
			throw new System.FormatException("Could NOT create Product from string " + productInfo);	
		}
	}
	
#endif
}



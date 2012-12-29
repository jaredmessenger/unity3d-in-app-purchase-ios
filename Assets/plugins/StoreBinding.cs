using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class PurchaseBinding 
{
#if UNITY_IPHONE
	[DllImport("__Internal")]
	private static extern void _initStoreWithProducts(string products);
	
	[DllImport("__Internal")]
	private static extern bool _canMakeStorePurchases();
	
	public static void initStore(string[] productArray)
	{
		string products = ArrayToString(productArray);
		
		_initStoreWithProducts(products);
		
		bool allowed =  _canMakeStorePurchases();
		
		Debug.Log("Is Allowed " + allowed);
		
	}
	
	public static string ArrayToString(string[] convertArray)
	{
		string returnString = string.Empty;
		for(int i=0; i<convertArray.Length; i++)
		{
			returnString += convertArray[i];
			if(i != convertArray.Length - 1)
			{
				returnString += ",";	
			}
		}
		
		return returnString;
	}
#endif
}



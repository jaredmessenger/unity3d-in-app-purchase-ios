using UnityEngine;
using System.Collections;

public class test_in_app_purchases_UI : MonoBehaviour 
{
	
	void Start ()
	{

	}

	void OnGUI () 
	{
		GUI.Box(new Rect(10,10,300,190), "Purchase Test");

		if(GUI.Button(new Rect(20,40,280,40), "Test Coins")) {
			StoreBinding.PurchaseProduct("coins");
		}

		if(GUI.Button(new Rect(20,90,280,40), "Test Turbo")) {
			StoreBinding.PurchaseProduct("turbo");
		}
		
		if(GUI.Button(new Rect(20, 140, 280, 40), "Get Products")){
			foreach(StoreProduct product in StoreManager.instance.ListProducts())
			{
				Debug.Log(product.Title);
			}
		}
	}
}

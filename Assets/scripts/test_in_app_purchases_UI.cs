using UnityEngine;
using System.Collections;

public class test_in_app_purchases_UI : MonoBehaviour 
{
	
	void Start ()
	{
		string[] products = {"coins", "turbo"};
		StoreBinding.LoadStore(products);
	}

	void OnGUI () 
	{
		GUI.Box(new Rect(10,10,300,190), "Purchase Test");

		if(GUI.Button(new Rect(20,40,280,40), "Test Coins")) {
			StoreBinding.PurchaseItem("coins");
		}

		if(GUI.Button(new Rect(20,90,280,40), "Test Turbo")) {
			StoreBinding.PurchaseItem("turbo");
		}
		
		if(GUI.Button(new Rect(20, 140, 280, 40), "Get Products")){
			Debug.Log("Grabbing Products");
		}
	}
}

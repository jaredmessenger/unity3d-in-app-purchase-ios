using UnityEngine;
using System.Collections;

public class test_in_app_purchases_UI : MonoBehaviour 
{
	
	void Start ()
	{
		string[] products = {"coins", "turbo"};
		PurchaseBinding.initStore(products);
	}

	void OnGUI () 
	{
		GUI.Box(new Rect(10,10,100,140), "Purchase Test");

		if(GUI.Button(new Rect(20,40,80,20), "Test Coins")) {
			
		}

		if(GUI.Button(new Rect(20,70,80,20), "Test Turbo")) {
			
		}
	}
}

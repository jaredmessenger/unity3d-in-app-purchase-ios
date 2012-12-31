using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class StoreManager : MonoBehaviour {
	
	public static StoreManager instance;
	
	public string receiptServer;
	
	string[] productIdentifiers = {"coins", "turbo"};
	List<StoreProduct> products = new List<StoreProduct>();
	
	void Awake()
	{
		if(instance)
			DestroyImmediate(gameObject);
		else
		{
			// Set the GameObject name to the class name for easy access from Obj-C
			gameObject.name = this.GetType().ToString();
			
			DontDestroyOnLoad(gameObject);
			instance = this;
		}
	}
	
	void Start () 
	{
		// Make sure the user has enabled purchases in their settings before doing anything
		if(StoreBinding.CanMakeStorePurchases())
		{
			StoreBinding.LoadStore(productIdentifiers);
			if(receiptServer != null)
			{
				Debug.Log("Adding Server Verification " + receiptServer);
				StoreBinding.SetReceiptVerificationServer(receiptServer.ToString());
			}
		}
	}
	
	public void	CallbackStoreLoadedSuccessfully(string empty)
	{
		// Called From Objective-C when the store has successfully finished loading
		StoreBinding.LoadStoreProductsWithInfo(productIdentifiers);
	}
	
	public void CallbackStoreLoadFailed(string empty)
	{
		Debug.Log("Store Failed to load");	
	}
	
	public void CallbackReceiveProductInfo(string info)
	{
		// Called From Objective-C After LoadStoreProductsWithInfo for each item
		
		StoreProduct product = StoreBinding.StringToProduct(info);
		products.Add(product);
	}
	
	public void CallbackProvideContent(string productIdentifier)
	{
		// Called from Objective-C when a store purchase succeeded
		Debug.Log("Purchase Succeeded " + productIdentifier);
	}
	
	public void CallbackTransactionFailed(string empty)
	{
		// Called from Objective-C when a transaction failed
		Debug.LogError("Purchase Failed");
	}
	
	public StoreProduct[] ListProducts()
	{
		// Make the List an Array to prevent Mutation outside this class
		
		StoreProduct[] productArray = new StoreProduct[products.Count];
		for(int i=0; i<products.Count; i++)
		{
			productArray[i] = products[i];
		}
		return productArray;
	}
}

public class StoreProduct
{
	private string _title;
	private string _description;
	private string _price;
	private string _productId;
	
	public StoreProduct(string title, string description, string price, string productId)
	{
		_title       = title;
		_description = description;
		_price       = price;
		_productId   = productId;
	}
	
	public string Title
	{
		get{ return _title; }	
	}
	
	public string Description
	{
		get{ return _description; }	
	}
	
	public string Price
	{
		get{ return _price; }	
	}
	
	public string ProductIdentifier
	{
		get{ return _productId; }	
	}
	
	
	
}

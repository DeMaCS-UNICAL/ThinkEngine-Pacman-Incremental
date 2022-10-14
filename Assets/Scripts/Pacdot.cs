using UnityEngine;
using System.Collections;

public class Pacdot : MonoBehaviour {
	//public int cont = 0;
	void OnTriggerEnter2D(Collider2D other)
	{
		if(other.name == "pacman")
		{
			GameManager.score += 10;
		    GameObject[] pacdots = GameObject.FindGameObjectsWithTag("pacdot");
            Destroy(gameObject);

		    if (pacdots.Length == 1)
		    {
		        GameObject.FindObjectOfType<GameGUINavigation>().LoadLevel();
		    }
		}
	}
    /*private void Update()
    {
        if (cont == 0)
        {
			cont = 1;
			GameObject p= Instantiate(FindObjectOfType<GameManager>().pacdotPrefab, transform.parent);
			p.name = "pacdot";
			p.tag = "pacdot";
			p.GetComponent<Pacdot>().cont = 1;
			p.transform.position=transform.position;
			DestroyImmediate(gameObject);
			
        }
    }*/
}

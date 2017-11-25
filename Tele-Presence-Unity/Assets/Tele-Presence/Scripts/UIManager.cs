using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIManager : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    public void EnterToMap() {

        UnityEngine.SceneManagement.SceneManager.LoadScene("IITCampus");

    }
    public void EnterToInterior()
    {
        UnityEngine.SceneManagement.SceneManager.LoadScene("chair");

    }

    public void EnterTophoto(){
		UnityEngine.SceneManagement.SceneManager.LoadScene("Demo");

	}
}

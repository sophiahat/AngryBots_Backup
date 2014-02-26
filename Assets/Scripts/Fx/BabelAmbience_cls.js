#pragma strict

var audio1 : AudioSource;
var audio2 : AudioSource;


function Start () {

	var gPitch : float = Random.Range(0.90, 1.10);
	var aSources = GetComponents(AudioSource) ;
	audio1 = aSources[0];
	audio2 = aSources[1];	
	
	
	audio1.pitch = gPitch;
	audio1.volume = 0.80;
	audio1.loop = true;
	audio1.Play();

	audio2.loop = true;
	audio2.priority = 0;
	audio2.volume = 1;
	audio2.Play();

}

function Update () {
	var Mech : GameObject = gameObject.Find("ConfusedEnemyMech");
	if(!Mech){	
		audio2.Stop();
	}
}
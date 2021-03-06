#pragma strict

var bulletPrefab : GameObject;
var frequency : float = 2;
var coneAngle : float = 1.5;
var fireSound : AudioClip[];
var firing : boolean = false;

private var lastFireTime : float = -1;


static function GetRandomSoundFromArray (audioClipArray : AudioClip[])  : AudioClip {
	if (audioClipArray.Length > 0) {
		return audioClipArray[Random.Range (0, audioClipArray.Length)];
	
	}


}
function Update () {
	if (firing) {
		if (Time.time > lastFireTime + 1 / frequency) {
			Fire ();
		}
	}
}

function Fire () {
	// Spawn bullet
	var coneRandomRotation = Quaternion.Euler (Random.Range (-coneAngle, coneAngle), Random.Range (-coneAngle, coneAngle), 0);
	Spawner.Spawn (bulletPrefab, transform.position, transform.rotation * coneRandomRotation);
	
	if (audio && fireSound) {
		audio.clip = GetRandomSoundFromArray (fireSound);
		audio.pitch = Random.Range(0.55, 1.55);
		Debug.Log(audio.pitch);
		audio.Play ();
	}
	
	lastFireTime = Time.time;
}

function OnStartFire () {
	firing = true;
}

function OnStopFire () {
	firing = false;
}
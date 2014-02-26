#pragma strict

@script RequireComponent (PerFrameRaycast)



var bulletPrefab : GameObject;
var spawnPoint : Transform;
var frequency : float = 10;
var coneAngle : float = 1.5;
var firing : boolean = false;
var damagePerSecond : float = 20.0;
var forcePerSecond : float = 20.0;
var hitSoundVolume : float = 0.5;

var muzzleFlashFront : GameObject;


// SVGA define audio sources for two layers of looping sounds on player guns and a release sound when done

var audio1: AudioSource; // main gun loop
var audio2: AudioSource; // starting sound (oneshot)
var audio3: AudioSource; // second layer sweetener loop high
var audio4: AudioSource; // release sound (oneshot)
var audio5: AudioSource; // third layer sweetener loop mid
var audio6: AudioSource; // fourth layer sweetener loop - low


private var lastFireTime : float = -1;
private var raycast : PerFrameRaycast;


// SVGA Get audio components for audio clips
function Start(){
	var aSources = GetComponents(AudioSource);
	audio1 = aSources[0];
	audio2 = aSources[1];
	audio3 = aSources[2];
	audio4 = aSources[3];
	audio5 = aSources[4];
	audio6 = aSources[5];
}

function Awake () {
	muzzleFlashFront.SetActive (false);

	raycast = GetComponent.<PerFrameRaycast> ();
	if (spawnPoint == null)
		spawnPoint = transform;
}

function Update () {
	if (firing) {

		if (Time.time > lastFireTime + 1 / frequency) {
			// Spawn visual bullet
			var coneRandomRotation = Quaternion.Euler (Random.Range (-coneAngle, coneAngle), Random.Range (-coneAngle, coneAngle), 0);
			var go : GameObject = Spawner.Spawn (bulletPrefab, spawnPoint.position, spawnPoint.rotation * coneRandomRotation) as GameObject;
			var bullet : SimpleBullet = go.GetComponent.<SimpleBullet> ();

			lastFireTime = Time.time;

			// Find the object hit by the raycast
			var hitInfo : RaycastHit = raycast.GetHitInfo ();
			if (hitInfo.transform) {
				// Get the health component of the target if any
				var targetHealth : Health = hitInfo.transform.GetComponent.<Health> ();
				if (targetHealth) {
					// Apply damage
					targetHealth.OnDamage (damagePerSecond / frequency, -spawnPoint.forward);
				}

				// Get the rigidbody if any
				if (hitInfo.rigidbody) {
					// Apply force to the target object at the position of the hit point
					var force : Vector3 = transform.forward * (forcePerSecond / frequency);
					hitInfo.rigidbody.AddForceAtPosition (force, hitInfo.point, ForceMode.Impulse);
				}

				// Ricochet sound
				var sound : AudioClip = MaterialImpactManager.GetBulletHitSound (hitInfo.collider.sharedMaterial);
				AudioSource.PlayClipAtPoint (sound, hitInfo.point, hitSoundVolume);

				bullet.dist = hitInfo.distance;
			}
			else {
				bullet.dist = 1000;
			}
		}
	}
}

function OnStartFire () {
	if (Time.timeScale == 0)
		return;

	firing = true;

	muzzleFlashFront.SetActive (true);
	
	//SVGA set global pitch randomization
	var gPitch: float = Random.Range(0.90, 1.10);
	
	
	//SVGA play the original loop using the first audio component
	if (audio1)
		audio1.pitch = gPitch;
		audio1.volume = 0.80;
		audio1.Play();
		
	//SVGA play the starting sound (firing)
	if (audio2)
		audio2.Play();
		
//SVGA play the high sweetener loop
	if (audio3)
		audio3.pitch = gPitch;
		audio3.volume = Random.Range(0.45, 0.95);
		audio3.Play();

//SVGA play the mid sweetener loop
	if (audio5)
		audio5.pitch = gPitch;
		audio5.volume = Random.Range(0.50, 0.95);
		audio5.Play();

//SVGA play the low sweetener loop
	if (audio6)
		audio6.pitch = gPitch;
		audio6.volume = Random.Range(0.75, 1);
		audio6.Play();

		
}

function OnStopFire () {
	firing = false;

	muzzleFlashFront.SetActive (false);


//SVGA stop main firing loop
	if (audio1)
		audio1.Stop();
		
// SVGA stop sweetener loop - high
	if (audio3)
		audio3.Stop();
		
// SVGA stop sweetener loop - medium
	if (audio5)
		audio5.Stop();
		
// SVGA stop sweetener loop - low
	if (audio6)
		audio6.Stop();

// SVGA play a release sound
	if (audio4)
		audio4.volume = 0.50;
		audio4.Play();
}
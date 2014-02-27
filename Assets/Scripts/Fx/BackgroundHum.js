#pragma strict

//var audioSource : AudioSource;
var backgroundHum : AudioClip[];

static function GetRandomSoundFromArray (audioClipArray : AudioClip[]) : AudioClip {
	if (audioClipArray.Length > 0)
		Debug.Log(audioClipArray[Random.Range(0, audioClipArray.Length)]);
		return audioClipArray[Random.Range (0, audioClipArray.Length)];
		
	
}

function Start () {
	var sound : AudioClip;
	sound = GetRandomSoundFromArray(backgroundHum);
	audio.loop = true;
	audio.clip = sound;
	audio.volume = Random.Range(0.19, 0.50);
	Debug.Log(audio.volume);
	audio.pitch = Random.Range(0.5, 1.9);
	audio.Play();
}


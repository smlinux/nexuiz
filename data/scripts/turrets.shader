models/turrets/tesla_chrome
{

	qer_editorimage models/turrets/chrome.tga

	//dp_reflect 0 0.75 0.75 1 0.5	
	{
		map models/turrets/chrome.tga	
		rgbGen vertex
		tcGen environment 
		tcMod scale 2 2
		
	}
}

models/turrets/phaser_beam
{
	surfaceparm trans
	cull none
	nopicmip

	qer_editorimage models/turrets/phaser_beam
	{		
		map models/turrets/phaser_beam
		blendFunc add
	}

}

models/turrets/reactor_beams
{
	surfaceparm trans
	cull none

	qer_editorimage models/turrets/reactor
	{		
		map models/turrets/reactor
		blendFunc add
	}
}


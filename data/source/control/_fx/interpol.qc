// DP/Nex Menu
// control/fx/interpol.qc

float( float pStart, float pEnd, float pDeltaTime, float pT, float pValue ) FX_LinearInterpolation =
{
	return pValue + ((pEnd - pStart) * Timer_Delta / pDeltaTime);
};

float( float pStart, float pEnd, float pDeltaTime, float pT, float pValue ) FX_SquareInterpolation =
{
	return pEnd - (pEnd - pStart) * (pDeltaTime - pT) * (pDeltaTime - pT) / pDeltaTime / pDeltaTime;
};

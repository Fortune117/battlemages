HEADER
{
    Description = "Blink test";
    DevShader = true;
}

MODES
{
    Default();
    VrForward();
}

FEATURES
{
}

COMMON
{
    #include "postprocess/shared.hlsl"
}

struct VertexInput
{
    float3 vPositionOs : POSITION < Semantic( PosXyz ); >;
    float2 vTexCoord : TEXCOORD0 < Semantic( LowPrecisionUv ); >;
};

struct PixelInput
{
    float2 vTexCoord : TEXCOORD0;

	// VS only
	#if ( PROGRAM == VFX_PROGRAM_VS )
		float4 vPositionPs		: SV_Position;
	#endif

	// PS only
	#if ( ( PROGRAM == VFX_PROGRAM_PS ) )
		float4 vPositionSs		: SV_ScreenPosition;
	#endif
};

VS
{
    PixelInput MainVs( VertexInput i )
    {
        PixelInput o;
        o.vPositionPs = float4(i.vPositionOs.xyz, 1.0f);
        o.vTexCoord = i.vTexCoord;
        return o;
    }
}

PS
{
    #include "postprocess/common.hlsl"

    RenderState( DepthWriteEnable, false );
    RenderState( DepthEnable, false );

    CreateTexture2D( g_tColorBuffer ) < Attribute( "ColorBuffer" );  	SrgbRead( true ); Filter( MIN_MAG_LINEAR_MIP_POINT ); AddressU( MIRROR ); AddressV( MIRROR ); >;
    CreateTexture2D( g_tDepthBuffer ) < Attribute( "DepthBuffer" ); 	SrgbRead( false ); Filter( MIN_MAG_MIP_POINT ); AddressU( CLAMP ); AddressV( CLAMP ); >;

	CreateTexture2D( g_tWarpTexture ) < Attribute( "blink.warp.texture" );  	SrgbRead( true ); Filter( MIN_MAG_LINEAR_MIP_POINT ); AddressU( WRAP ); AddressV( WRAP ); >;

    float flBlinkFraction< Attribute("blink.warp.fraction"); Default(0.0f); >;

    float4 MainPs( PixelInput i ) : SV_Target0
    {
		const float flWarpWeight = 0.25f;

        // Get the current screen texture coordinates
        float2 vScreenUv = i.vPositionSs.xy / g_vRenderTargetSize;

		float3 vWarpColor = Tex2D(g_tWarpTexture, vScreenUv.xy).rgb;

		float2 vMidPoint = float2(0.5f, 0.5f);
		float2 vWarpOffset = lerp(vScreenUv.xy, vMidPoint, vWarpColor.r * flWarpWeight * flBlinkFraction);

        // Get the current color at a given pixel
        float3 vFrameBufferColor = Tex2D( g_tColorBuffer, vWarpOffset).rgb;
        
        // Invert the color and write it to our output
        return float4( vFrameBufferColor, 1.0f );
    }
}

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'


Shader "newshader/particle" {

	Properties{
		_MainTex("Base texture", 2D) = "white" {}
	_MainTex1("Base texture1", 2D) = "white" {}
	_Color("Color", Color) = (1,1,1,1)
		_Color1("Color1", Color) = (1,1,1,1)
		_Size("Size",float) = 0.1
		_rpos("_RPos",Vector) = (0,0,0,0)
		_h("_h",float) = 110
		_w("_w",float) = 110
		_gap("_gap",float) = 20
	}
		SubShader{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off Lighting Off ZWrite Off

		CGINCLUDE
#include "UnityCG.cginc"
		sampler2D _MainTex;
	sampler2D _MainTex1;
	float4 _Color;
	float4 _Color1;
	float _Size;
	float _w;
	float _h;
	float4 _rpos;
	float3 _wpos;
	float _gap;

	struct v2f {
		float4	pos	: SV_POSITION;
		float2	uv		: TEXCOORD0;
		fixed4	color : TEXCOORD1;
		float2 uv1:TEXCOORD2;
	};
	float2 offsetUV(int k, float num, float col, float row)//num=row*col
	{
		k = fmod(k, num);
		int r = k / col;
		int c = fmod(k, col);//第c列
		return float2(1 / col *c, -1 / row*r);
	}
	float hash(float n)
	{
		return frac(sin(n)*43758.5453);
	}
	float3 rndVec(float value)
	{
		float t0 = hash(value);
		float t1 = hash(t0);
		float t2 = hash(t1);
		float t3 = hash(t2);
		float t4 = hash(t3);
		float t5 = hash(t4);
		return normalize(float3(t0 - t3, t4 - t5,t1 - t2));
	}
	float nv(float value)
	{
		return  (value + 1)*0.5f;
	}
	v2f vert(appdata_full v)
	{
		v2f 		o;
		float row = 4;
		float col = 5;
		float num = row*col;
		float kv = (_Time.z*2 + v.color.a * 50000) / 10;
		float kk = frac(kv);
		kv = floor(kv);

		float tm = v.color.b;
		float3 xz = rndVec(kv);
		float hkv = hash(kv);
		float3 fp = float3(xz.x, 0.0f, xz.y).xyz*hkv;
		float spz = sign(hkv - hash(kv + 8));
		float3 dtxz = sign(_rpos);
		float fp0 = (_h < 20) ? 1 : 0;
		float fp1 = fp0* sign(hkv - hash(kv + 2)) + 1 - fp0;
		float fp3 = (fp0 + 1);// *2;
		float ky = tm*kk * 10;
		float gap = _gap;

		float3 t3 = _rpos / (float3(_w,0,_h) * 4);// +1.0f;
		if (spz >= 0)
		{
			fp.x = (_w + nv(fp.x)*gap) *dtxz.x*fp1;
			fp.z = (frac(nv(xz.y) - t3.z)*_h-_h*0.5f)*fp3 + _rpos.z;
			fp.y += ky;
		}
		else
		{
			fp.x = (frac(nv(xz.z) - t3.x)*_w-_w*0.5f)*fp3 + _rpos.x;
			fp.z = (_h + nv(fp.z)*gap) *dtxz.z*fp1;
			fp.y += ky;
		}
		v.vertex.xyz += fp + float3(0,0,ky);
		float2	xzo = float(0.5).xx - v.color.rg;
		float3	centerOffs = float3(xzo.x, 0,xzo.y);
		float3	centerLocal = v.vertex.xyz + centerOffs.xyz;
		float  ttt = tm*-2.0f;
		float3	BBLocalPos = centerLocal - (float3(5.0f + ttt,0,0) * centerOffs.x + float3(0,0,5.0f + ttt) * centerOffs.z);
		float2 uv = v.texcoord.xy;
		o.uv = (tm == 1) ? uv : float2(uv.x / col, (uv.y - 1) / row) + offsetUV(kk * 20, num, col, row);
		o.pos = UnityObjectToClipPos(float4(BBLocalPos - float3(_wpos.x,0,_wpos.z),1));
		o.color = _Color1*float4(1,1,1,1 - kk);
		o.uv1 = tm;
		return o;
	}
	ENDCG
		Pass{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest		
		fixed4 frag(v2f i) : COLOR
	{
		fixed4 o = tex2D(_MainTex, i.uv.xy) * _Color;
	fixed4 o1 = tex2D(_MainTex1, i.uv.xy) * i.color;
	return (1 - i.uv1.x)*o + i.uv1.x*o1;
	//o.xyz*=o.a;
	return o;
	}
		ENDCG
	}
	}


}


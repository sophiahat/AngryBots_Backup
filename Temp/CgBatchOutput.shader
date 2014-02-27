
/* 

one of the most common shader in AngryBots

same as ReflectiveBackgroundPlanarGeometry but falls back
to a simpler lightmap-apply-only shader.

as this shader is used for arbitrary geometry, it is biasing the
normal a little towards the viewer to create a less dramatic specular
look

*/

Shader "AngryBots/ReflectiveBackgroundArbitraryGeometry" {
	
Properties {
	_MainTex ("Base", 2D) = "white" {}
	_Normal("Normal", 2D) = "bump" {}
	_Cube("Cube", CUBE) = "black" {}
	_OneMinusReflectivity("OneMinusReflectivity", Range(0.0, 1.0)) = 0.05
}


#LINE 51
 

SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 300 
	
	Pass {
		Program "vp" {
// Vertex combos: 2
//   opengl - ALU: 30 to 30
//   d3d9 - ALU: 33 to 33
//   d3d11 - ALU: 28 to 29, TEX: 0 to 0, FLOW: 1 to 1
//   d3d11_9x - ALU: 28 to 29, TEX: 0 to 0, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { "LIGHTMAP_OFF" }
Bind "vertex" Vertex
Bind "tangent" ATTR14
Bind "normal" Normal
Bind "texcoord" TexCoord0
Vector 9 [_WorldSpaceCameraPos]
Matrix 5 [_Object2World]
Vector 10 [unity_Scale]
Vector 11 [_MainTex_ST]
"!!ARBvp1.0
# 30 ALU
PARAM c[12] = { { 0 },
		state.matrix.mvp,
		program.local[5..11] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
MOV R1.w, c[10];
MUL R2.xyz, R1.w, c[5];
MUL R3.xyz, R1.w, c[6];
MUL R4.xyz, R1.w, c[7];
MOV R0.xyz, vertex.attrib[14];
MUL R1.xyz, vertex.normal.zxyw, R0.yzxw;
MAD R0.xyz, vertex.normal.yzxw, R0.zxyw, -R1;
MUL R1.xyz, R0, vertex.attrib[14].w;
DP4 R0.z, vertex.position, c[7];
DP4 R0.x, vertex.position, c[5];
DP4 R0.y, vertex.position, c[6];
ADD R0.xyz, -R0, c[9];
DP3 R0.w, R0, R0;
RSQ R0.w, R0.w;
DP3 result.texcoord[2].y, R2, R1;
DP3 result.texcoord[3].y, R1, R3;
DP3 result.texcoord[4].y, R1, R4;
MUL result.texcoord[5].xyz, R0.w, R0;
DP3 result.texcoord[2].z, vertex.normal, R2;
DP3 result.texcoord[2].x, R2, vertex.attrib[14];
DP3 result.texcoord[3].z, vertex.normal, R3;
DP3 result.texcoord[3].x, vertex.attrib[14], R3;
DP3 result.texcoord[4].z, vertex.normal, R4;
DP3 result.texcoord[4].x, vertex.attrib[14], R4;
MOV result.texcoord[0].zw, c[0].x;
MAD result.texcoord[0].xy, vertex.texcoord[0], c[11], c[11].zwzw;
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 30 instructions, 5 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_OFF" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Matrix 4 [_Object2World]
Vector 9 [unity_Scale]
Vector 10 [_MainTex_ST]
"vs_2_0
; 33 ALU
def c11, 0.00000000, 0, 0, 0
dcl_position0 v0
dcl_tangent0 v1
dcl_normal0 v2
dcl_texcoord0 v3
mov r0.xyz, v1
mul r1.xyz, v2.zxyw, r0.yzxw
mov r0.xyz, v1
mad r0.xyz, v2.yzxw, r0.zxyw, -r1
mul r2.xyz, r0, v1.w
mov r0.xyz, c4
mul r3.xyz, c9.w, r0
mov r1.xyz, c5
mul r4.xyz, c9.w, r1
dp4 r0.z, v0, c6
dp4 r0.x, v0, c4
dp4 r0.y, v0, c5
add r1.xyz, -r0, c8
mov r0.xyz, c6
mul r0.xyz, c9.w, r0
dp3 r0.w, r1, r1
rsq r0.w, r0.w
dp3 oT2.y, r3, r2
dp3 oT3.y, r2, r4
dp3 oT4.y, r2, r0
mul oT5.xyz, r0.w, r1
dp3 oT2.z, v2, r3
dp3 oT2.x, r3, v1
dp3 oT3.z, v2, r4
dp3 oT3.x, v1, r4
dp3 oT4.z, v2, r0
dp3 oT4.x, v1, r0
mov oT0.zw, c11.x
mad oT0.xy, v3, c10, c10.zwzw
dp4 oPos.w, v0, c3
dp4 oPos.z, v0, c2
dp4 oPos.y, v0, c1
dp4 oPos.x, v0, c0
"
}

SubProgram "d3d11 " {
Keywords { "LIGHTMAP_OFF" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord" TexCoord0
Bind "color" Color
ConstBuffer "$Globals" 64 // 64 used size, 4 vars
Vector 48 [_MainTex_ST] 4
ConstBuffer "UnityPerCamera" 128 // 76 used size, 8 vars
Vector 64 [_WorldSpaceCameraPos] 3
ConstBuffer "UnityPerDraw" 336 // 336 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
Matrix 192 [_Object2World] 4
Vector 320 [unity_Scale] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
BindCB "UnityPerDraw" 2
// 39 instructions, 2 temp regs, 0 temp arrays:
// ALU 28 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0
eefiecedkffjhibokgahnhjoeinbhnbemhflaaphabaaaaaapeagaaaaadaaaaaa
cmaaaaaapeaaaaaakmabaaaaejfdeheomaaaaaaaagaaaaaaaiaaaaaajiaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaakbaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaakjaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
ahahaaaalaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaadaaaaaaapadaaaalaaaaaaa
abaaaaaaaaaaaaaaadaaaaaaaeaaaaaaapaaaaaaljaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaafaaaaaaapaaaaaafaepfdejfeejepeoaafeebeoehefeofeaaeoepfc
enebemaafeeffiedepepfceeaaedepemepfcaaklepfdeheolaaaaaaaagaaaaaa
aiaaaaaajiaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaakeaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapaaaaaakeaaaaaaacaaaaaaaaaaaaaa
adaaaaaaacaaaaaaahaiaaaakeaaaaaaadaaaaaaaaaaaaaaadaaaaaaadaaaaaa
ahaiaaaakeaaaaaaaeaaaaaaaaaaaaaaadaaaaaaaeaaaaaaahaiaaaakeaaaaaa
afaaaaaaaaaaaaaaadaaaaaaafaaaaaaahaiaaaafdfgfpfaepfdejfeejepeoaa
feeffiedepepfceeaaklklklfdeieefceaafaaaaeaaaabaafaabaaaafjaaaaae
egiocaaaaaaaaaaaaeaaaaaafjaaaaaeegiocaaaabaaaaaaafaaaaaafjaaaaae
egiocaaaacaaaaaabfaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaadpcbabaaa
abaaaaaafpaaaaadhcbabaaaacaaaaaafpaaaaaddcbabaaaadaaaaaaghaaaaae
pccabaaaaaaaaaaaabaaaaaagfaaaaadpccabaaaabaaaaaagfaaaaadhccabaaa
acaaaaaagfaaaaadhccabaaaadaaaaaagfaaaaadhccabaaaaeaaaaaagfaaaaad
hccabaaaafaaaaaagiaaaaacacaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaa
aaaaaaaaegiocaaaacaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaa
acaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaa
aaaaaaaaegiocaaaacaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaa
dcaaaaakpccabaaaaaaaaaaaegiocaaaacaaaaaaadaaaaaapgbpbaaaaaaaaaaa
egaobaaaaaaaaaaadcaaaaaldccabaaaabaaaaaaegbabaaaadaaaaaaegiacaaa
aaaaaaaaadaaaaaaogikcaaaaaaaaaaaadaaaaaadgaaaaaimccabaaaabaaaaaa
aceaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaadgaaaaagbcaabaaaaaaaaaaa
akiacaaaacaaaaaaamaaaaaadgaaaaagccaabaaaaaaaaaaaakiacaaaacaaaaaa
anaaaaaadgaaaaagecaabaaaaaaaaaaaakiacaaaacaaaaaaaoaaaaaadiaaaaai
hcaabaaaaaaaaaaaegacbaaaaaaaaaaapgipcaaaacaaaaaabeaaaaaabaaaaaah
bccabaaaacaaaaaaegbcbaaaabaaaaaaegacbaaaaaaaaaaabaaaaaaheccabaaa
acaaaaaaegbcbaaaacaaaaaaegacbaaaaaaaaaaadiaaaaahhcaabaaaabaaaaaa
jgbebaaaabaaaaaacgbjbaaaacaaaaaadcaaaaakhcaabaaaabaaaaaajgbebaaa
acaaaaaacgbjbaaaabaaaaaaegacbaiaebaaaaaaabaaaaaadiaaaaahhcaabaaa
abaaaaaaegacbaaaabaaaaaapgbpbaaaabaaaaaabaaaaaahcccabaaaacaaaaaa
egacbaaaabaaaaaaegacbaaaaaaaaaaadgaaaaagbcaabaaaaaaaaaaabkiacaaa
acaaaaaaamaaaaaadgaaaaagccaabaaaaaaaaaaabkiacaaaacaaaaaaanaaaaaa
dgaaaaagecaabaaaaaaaaaaabkiacaaaacaaaaaaaoaaaaaadiaaaaaihcaabaaa
aaaaaaaaegacbaaaaaaaaaaapgipcaaaacaaaaaabeaaaaaabaaaaaahcccabaaa
adaaaaaaegacbaaaabaaaaaaegacbaaaaaaaaaaabaaaaaahbccabaaaadaaaaaa
egbcbaaaabaaaaaaegacbaaaaaaaaaaabaaaaaaheccabaaaadaaaaaaegbcbaaa
acaaaaaaegacbaaaaaaaaaaadgaaaaagbcaabaaaaaaaaaaackiacaaaacaaaaaa
amaaaaaadgaaaaagccaabaaaaaaaaaaackiacaaaacaaaaaaanaaaaaadgaaaaag
ecaabaaaaaaaaaaackiacaaaacaaaaaaaoaaaaaadiaaaaaihcaabaaaaaaaaaaa
egacbaaaaaaaaaaapgipcaaaacaaaaaabeaaaaaabaaaaaahcccabaaaaeaaaaaa
egacbaaaabaaaaaaegacbaaaaaaaaaaabaaaaaahbccabaaaaeaaaaaaegbcbaaa
abaaaaaaegacbaaaaaaaaaaabaaaaaaheccabaaaaeaaaaaaegbcbaaaacaaaaaa
egacbaaaaaaaaaaadiaaaaaihcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiccaaa
acaaaaaaanaaaaaadcaaaaakhcaabaaaaaaaaaaaegiccaaaacaaaaaaamaaaaaa
agbabaaaaaaaaaaaegacbaaaaaaaaaaadcaaaaakhcaabaaaaaaaaaaaegiccaaa
acaaaaaaaoaaaaaakgbkbaaaaaaaaaaaegacbaaaaaaaaaaadcaaaaakhcaabaaa
aaaaaaaaegiccaaaacaaaaaaapaaaaaapgbpbaaaaaaaaaaaegacbaaaaaaaaaaa
aaaaaaajhcaabaaaaaaaaaaaegacbaiaebaaaaaaaaaaaaaaegiccaaaabaaaaaa
aeaaaaaabaaaaaahicaabaaaaaaaaaaaegacbaaaaaaaaaaaegacbaaaaaaaaaaa
eeaaaaaficaabaaaaaaaaaaadkaabaaaaaaaaaaadiaaaaahhccabaaaafaaaaaa
pgapbaaaaaaaaaaaegacbaaaaaaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_OFF" }
"!!GLES


#ifdef VERTEX

varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying mediump vec3 xlv_TEXCOORD2;
varying mediump vec4 xlv_TEXCOORD0;
uniform highp vec4 _MainTex_ST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec4 _glesMultiTexCoord0;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  mediump vec4 tmpvar_3;
  mediump vec3 tmpvar_4;
  highp vec2 tmpvar_5;
  tmpvar_5 = ((_glesMultiTexCoord0.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
  tmpvar_3.xy = tmpvar_5;
  tmpvar_3.zw = vec2(0.0, 0.0);
  highp vec3 tmpvar_6;
  tmpvar_6 = normalize((_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz));
  tmpvar_4 = tmpvar_6;
  mediump vec3 ts0_7;
  mediump vec3 ts1_8;
  mediump vec3 ts2_9;
  highp vec3 tmpvar_10;
  highp vec3 tmpvar_11;
  tmpvar_10 = tmpvar_1.xyz;
  tmpvar_11 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_12;
  tmpvar_12[0].x = tmpvar_10.x;
  tmpvar_12[0].y = tmpvar_11.x;
  tmpvar_12[0].z = tmpvar_2.x;
  tmpvar_12[1].x = tmpvar_10.y;
  tmpvar_12[1].y = tmpvar_11.y;
  tmpvar_12[1].z = tmpvar_2.y;
  tmpvar_12[2].x = tmpvar_10.z;
  tmpvar_12[2].y = tmpvar_11.z;
  tmpvar_12[2].z = tmpvar_2.z;
  vec4 v_13;
  v_13.x = _Object2World[0].x;
  v_13.y = _Object2World[1].x;
  v_13.z = _Object2World[2].x;
  v_13.w = _Object2World[3].x;
  highp vec3 tmpvar_14;
  tmpvar_14 = (tmpvar_12 * (v_13.xyz * unity_Scale.w));
  ts0_7 = tmpvar_14;
  vec4 v_15;
  v_15.x = _Object2World[0].y;
  v_15.y = _Object2World[1].y;
  v_15.z = _Object2World[2].y;
  v_15.w = _Object2World[3].y;
  highp vec3 tmpvar_16;
  tmpvar_16 = (tmpvar_12 * (v_15.xyz * unity_Scale.w));
  ts1_8 = tmpvar_16;
  vec4 v_17;
  v_17.x = _Object2World[0].z;
  v_17.y = _Object2World[1].z;
  v_17.z = _Object2World[2].z;
  v_17.w = _Object2World[3].z;
  highp vec3 tmpvar_18;
  tmpvar_18 = (tmpvar_12 * (v_17.xyz * unity_Scale.w));
  ts2_9 = tmpvar_18;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_3;
  xlv_TEXCOORD2 = ts0_7;
  xlv_TEXCOORD3 = ts1_8;
  xlv_TEXCOORD4 = ts2_9;
  xlv_TEXCOORD5 = tmpvar_4;
}



#endif
#ifdef FRAGMENT

varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying mediump vec3 xlv_TEXCOORD2;
varying mediump vec4 xlv_TEXCOORD0;
uniform mediump float _OneMinusReflectivity;
uniform samplerCube _Cube;
uniform sampler2D _Normal;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tex_1;
  mediump vec3 nrml_2;
  lowp vec3 tmpvar_3;
  tmpvar_3 = ((texture2D (_Normal, xlv_TEXCOORD0.xy).xyz * 2.0) - 1.0);
  nrml_2 = tmpvar_3;
  mediump vec3 tmpvar_4;
  tmpvar_4.x = dot (xlv_TEXCOORD2, nrml_2);
  tmpvar_4.y = dot (xlv_TEXCOORD3, nrml_2);
  tmpvar_4.z = dot (xlv_TEXCOORD4, nrml_2);
  mediump vec3 tmpvar_5;
  tmpvar_5 = ((tmpvar_4 + xlv_TEXCOORD5) * 0.5);
  lowp vec4 tmpvar_6;
  tmpvar_6 = texture2D (_MainTex, xlv_TEXCOORD0.xy);
  mediump vec3 tmpvar_7;
  mediump vec3 i_8;
  i_8 = -(xlv_TEXCOORD5);
  tmpvar_7 = (i_8 - (2.0 * (dot (tmpvar_5, i_8) * tmpvar_5)));
  mediump float tmpvar_9;
  tmpvar_9 = clamp ((tmpvar_6.w - _OneMinusReflectivity), 0.0, 1.0);
  lowp vec4 tmpvar_10;
  tmpvar_10 = (tmpvar_6 + (textureCube (_Cube, tmpvar_7) * tmpvar_9));
  tex_1.w = tmpvar_10.w;
  tex_1.xyz = (tmpvar_10.xyz * 0.75);
  gl_FragData[0] = tex_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_OFF" }
"!!GLES


#ifdef VERTEX

varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying mediump vec3 xlv_TEXCOORD2;
varying mediump vec4 xlv_TEXCOORD0;
uniform highp vec4 _MainTex_ST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec4 _glesMultiTexCoord0;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  mediump vec4 tmpvar_3;
  mediump vec3 tmpvar_4;
  highp vec2 tmpvar_5;
  tmpvar_5 = ((_glesMultiTexCoord0.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
  tmpvar_3.xy = tmpvar_5;
  tmpvar_3.zw = vec2(0.0, 0.0);
  highp vec3 tmpvar_6;
  tmpvar_6 = normalize((_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz));
  tmpvar_4 = tmpvar_6;
  mediump vec3 ts0_7;
  mediump vec3 ts1_8;
  mediump vec3 ts2_9;
  highp vec3 tmpvar_10;
  highp vec3 tmpvar_11;
  tmpvar_10 = tmpvar_1.xyz;
  tmpvar_11 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_12;
  tmpvar_12[0].x = tmpvar_10.x;
  tmpvar_12[0].y = tmpvar_11.x;
  tmpvar_12[0].z = tmpvar_2.x;
  tmpvar_12[1].x = tmpvar_10.y;
  tmpvar_12[1].y = tmpvar_11.y;
  tmpvar_12[1].z = tmpvar_2.y;
  tmpvar_12[2].x = tmpvar_10.z;
  tmpvar_12[2].y = tmpvar_11.z;
  tmpvar_12[2].z = tmpvar_2.z;
  vec4 v_13;
  v_13.x = _Object2World[0].x;
  v_13.y = _Object2World[1].x;
  v_13.z = _Object2World[2].x;
  v_13.w = _Object2World[3].x;
  highp vec3 tmpvar_14;
  tmpvar_14 = (tmpvar_12 * (v_13.xyz * unity_Scale.w));
  ts0_7 = tmpvar_14;
  vec4 v_15;
  v_15.x = _Object2World[0].y;
  v_15.y = _Object2World[1].y;
  v_15.z = _Object2World[2].y;
  v_15.w = _Object2World[3].y;
  highp vec3 tmpvar_16;
  tmpvar_16 = (tmpvar_12 * (v_15.xyz * unity_Scale.w));
  ts1_8 = tmpvar_16;
  vec4 v_17;
  v_17.x = _Object2World[0].z;
  v_17.y = _Object2World[1].z;
  v_17.z = _Object2World[2].z;
  v_17.w = _Object2World[3].z;
  highp vec3 tmpvar_18;
  tmpvar_18 = (tmpvar_12 * (v_17.xyz * unity_Scale.w));
  ts2_9 = tmpvar_18;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_3;
  xlv_TEXCOORD2 = ts0_7;
  xlv_TEXCOORD3 = ts1_8;
  xlv_TEXCOORD4 = ts2_9;
  xlv_TEXCOORD5 = tmpvar_4;
}



#endif
#ifdef FRAGMENT

varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying mediump vec3 xlv_TEXCOORD2;
varying mediump vec4 xlv_TEXCOORD0;
uniform mediump float _OneMinusReflectivity;
uniform samplerCube _Cube;
uniform sampler2D _Normal;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tex_1;
  mediump vec3 nrml_2;
  lowp vec3 normal_3;
  normal_3.xy = ((texture2D (_Normal, xlv_TEXCOORD0.xy).wy * 2.0) - 1.0);
  normal_3.z = sqrt((1.0 - clamp (dot (normal_3.xy, normal_3.xy), 0.0, 1.0)));
  nrml_2 = normal_3;
  mediump vec3 tmpvar_4;
  tmpvar_4.x = dot (xlv_TEXCOORD2, nrml_2);
  tmpvar_4.y = dot (xlv_TEXCOORD3, nrml_2);
  tmpvar_4.z = dot (xlv_TEXCOORD4, nrml_2);
  mediump vec3 tmpvar_5;
  tmpvar_5 = ((tmpvar_4 + xlv_TEXCOORD5) * 0.5);
  lowp vec4 tmpvar_6;
  tmpvar_6 = texture2D (_MainTex, xlv_TEXCOORD0.xy);
  mediump vec3 tmpvar_7;
  mediump vec3 i_8;
  i_8 = -(xlv_TEXCOORD5);
  tmpvar_7 = (i_8 - (2.0 * (dot (tmpvar_5, i_8) * tmpvar_5)));
  mediump float tmpvar_9;
  tmpvar_9 = clamp ((tmpvar_6.w - _OneMinusReflectivity), 0.0, 1.0);
  lowp vec4 tmpvar_10;
  tmpvar_10 = (tmpvar_6 + (textureCube (_Cube, tmpvar_7) * tmpvar_9));
  tex_1.w = tmpvar_10.w;
  tex_1.xyz = (tmpvar_10.xyz * 0.75);
  gl_FragData[0] = tex_1;
}



#endif"
}

SubProgram "flash " {
Keywords { "LIGHTMAP_OFF" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Matrix 4 [_Object2World]
Vector 9 [unity_Scale]
Vector 10 [_MainTex_ST]
"agal_vs
c11 0.0 0.0 0.0 0.0
[bc]
aaaaaaaaaaaaahacafaaaaoeaaaaaaaaaaaaaaaaaaaaaaaa mov r0.xyz, a5
adaaaaaaabaaahacabaaaancaaaaaaaaaaaaaaajacaaaaaa mul r1.xyz, a1.zxyw, r0.yzxx
aaaaaaaaaaaaahacafaaaaoeaaaaaaaaaaaaaaaaaaaaaaaa mov r0.xyz, a5
adaaaaaaacaaahacabaaaamjaaaaaaaaaaaaaafcacaaaaaa mul r2.xyz, a1.yzxw, r0.zxyy
acaaaaaaaaaaahacacaaaakeacaaaaaaabaaaakeacaaaaaa sub r0.xyz, r2.xyzz, r1.xyzz
adaaaaaaacaaahacaaaaaakeacaaaaaaafaaaappaaaaaaaa mul r2.xyz, r0.xyzz, a5.w
aaaaaaaaaaaaahacaeaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r0.xyz, c4
adaaaaaaadaaahacajaaaappabaaaaaaaaaaaakeacaaaaaa mul r3.xyz, c9.w, r0.xyzz
aaaaaaaaabaaahacafaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r1.xyz, c5
adaaaaaaaeaaahacajaaaappabaaaaaaabaaaakeacaaaaaa mul r4.xyz, c9.w, r1.xyzz
bdaaaaaaaaaaaeacaaaaaaoeaaaaaaaaagaaaaoeabaaaaaa dp4 r0.z, a0, c6
bdaaaaaaaaaaabacaaaaaaoeaaaaaaaaaeaaaaoeabaaaaaa dp4 r0.x, a0, c4
bdaaaaaaaaaaacacaaaaaaoeaaaaaaaaafaaaaoeabaaaaaa dp4 r0.y, a0, c5
bfaaaaaaabaaahacaaaaaakeacaaaaaaaaaaaaaaaaaaaaaa neg r1.xyz, r0.xyzz
abaaaaaaabaaahacabaaaakeacaaaaaaaiaaaaoeabaaaaaa add r1.xyz, r1.xyzz, c8
aaaaaaaaaaaaahacagaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r0.xyz, c6
adaaaaaaaaaaahacajaaaappabaaaaaaaaaaaakeacaaaaaa mul r0.xyz, c9.w, r0.xyzz
bcaaaaaaaaaaaiacabaaaakeacaaaaaaabaaaakeacaaaaaa dp3 r0.w, r1.xyzz, r1.xyzz
akaaaaaaaaaaaiacaaaaaappacaaaaaaaaaaaaaaaaaaaaaa rsq r0.w, r0.w
bcaaaaaaacaaacaeadaaaakeacaaaaaaacaaaakeacaaaaaa dp3 v2.y, r3.xyzz, r2.xyzz
bcaaaaaaadaaacaeacaaaakeacaaaaaaaeaaaakeacaaaaaa dp3 v3.y, r2.xyzz, r4.xyzz
bcaaaaaaaeaaacaeacaaaakeacaaaaaaaaaaaakeacaaaaaa dp3 v4.y, r2.xyzz, r0.xyzz
adaaaaaaafaaahaeaaaaaappacaaaaaaabaaaakeacaaaaaa mul v5.xyz, r0.w, r1.xyzz
bcaaaaaaacaaaeaeabaaaaoeaaaaaaaaadaaaakeacaaaaaa dp3 v2.z, a1, r3.xyzz
bcaaaaaaacaaabaeadaaaakeacaaaaaaafaaaaoeaaaaaaaa dp3 v2.x, r3.xyzz, a5
bcaaaaaaadaaaeaeabaaaaoeaaaaaaaaaeaaaakeacaaaaaa dp3 v3.z, a1, r4.xyzz
bcaaaaaaadaaabaeafaaaaoeaaaaaaaaaeaaaakeacaaaaaa dp3 v3.x, a5, r4.xyzz
bcaaaaaaaeaaaeaeabaaaaoeaaaaaaaaaaaaaakeacaaaaaa dp3 v4.z, a1, r0.xyzz
bcaaaaaaaeaaabaeafaaaaoeaaaaaaaaaaaaaakeacaaaaaa dp3 v4.x, a5, r0.xyzz
aaaaaaaaaaaaamaealaaaaaaabaaaaaaaaaaaaaaaaaaaaaa mov v0.zw, c11.x
adaaaaaaaaaaadacadaaaaoeaaaaaaaaakaaaaoeabaaaaaa mul r0.xy, a3, c10
abaaaaaaaaaaadaeaaaaaafeacaaaaaaakaaaaooabaaaaaa add v0.xy, r0.xyyy, c10.zwzw
bdaaaaaaaaaaaiadaaaaaaoeaaaaaaaaadaaaaoeabaaaaaa dp4 o0.w, a0, c3
bdaaaaaaaaaaaeadaaaaaaoeaaaaaaaaacaaaaoeabaaaaaa dp4 o0.z, a0, c2
bdaaaaaaaaaaacadaaaaaaoeaaaaaaaaabaaaaoeabaaaaaa dp4 o0.y, a0, c1
bdaaaaaaaaaaabadaaaaaaoeaaaaaaaaaaaaaaoeabaaaaaa dp4 o0.x, a0, c0
aaaaaaaaacaaaiaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v2.w, c0
aaaaaaaaadaaaiaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v3.w, c0
aaaaaaaaaeaaaiaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v4.w, c0
aaaaaaaaafaaaiaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v5.w, c0
"
}

SubProgram "d3d11_9x " {
Keywords { "LIGHTMAP_OFF" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord" TexCoord0
Bind "color" Color
ConstBuffer "$Globals" 64 // 64 used size, 4 vars
Vector 48 [_MainTex_ST] 4
ConstBuffer "UnityPerCamera" 128 // 76 used size, 8 vars
Vector 64 [_WorldSpaceCameraPos] 3
ConstBuffer "UnityPerDraw" 336 // 336 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
Matrix 192 [_Object2World] 4
Vector 320 [unity_Scale] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
BindCB "UnityPerDraw" 2
// 39 instructions, 2 temp regs, 0 temp arrays:
// ALU 28 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0_level_9_1
eefiecedfpfhfphejapbljlhbfhpndpodiobhnibabaaaaaadeakaaaaaeaaaaaa
daaaaaaagmadaaaaleaiaaaahmajaaaaebgpgodjdeadaaaadeadaaaaaaacpopp
naacaaaageaaaaaaafaaceaaaaaagaaaaaaagaaaaaaaceaaabaagaaaaaaaadaa
abaaabaaaaaaaaaaabaaaeaaabaaacaaaaaaaaaaacaaaaaaaeaaadaaaaaaaaaa
acaaamaaaeaaahaaaaaaaaaaacaabeaaabaaalaaaaaaaaaaaaaaaaaaaaacpopp
fbaaaaafamaaapkaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabpaaaaacafaaaaia
aaaaapjabpaaaaacafaaabiaabaaapjabpaaaaacafaaaciaacaaapjabpaaaaac
afaaadiaadaaapjaaeaaaaaeaaaaadoaadaaoejaabaaoekaabaaookaafaaaaad
aaaaahiaaaaaffjaaiaaoekaaeaaaaaeaaaaahiaahaaoekaaaaaaajaaaaaoeia
aeaaaaaeaaaaahiaajaaoekaaaaakkjaaaaaoeiaaeaaaaaeaaaaahiaakaaoeka
aaaappjaaaaaoeiaacaaaaadaaaaahiaaaaaoeibacaaoekaaiaaaaadaaaaaiia
aaaaoeiaaaaaoeiaahaaaaacaaaaaiiaaaaappiaafaaaaadaeaaahoaaaaappia
aaaaoeiaabaaaaacaaaaabiaahaaaakaabaaaaacaaaaaciaaiaaaakaabaaaaac
aaaaaeiaajaaaakaafaaaaadaaaaahiaaaaaoeiaalaappkaaiaaaaadabaaaboa
abaaoejaaaaaoeiaabaaaaacabaaahiaabaaoejaafaaaaadacaaahiaabaamjia
acaancjaaeaaaaaeabaaahiaacaamjjaabaanciaacaaoeibafaaaaadabaaahia
abaaoeiaabaappjaaiaaaaadabaaacoaabaaoeiaaaaaoeiaaiaaaaadabaaaeoa
acaaoejaaaaaoeiaabaaaaacaaaaabiaahaaffkaabaaaaacaaaaaciaaiaaffka
abaaaaacaaaaaeiaajaaffkaafaaaaadaaaaahiaaaaaoeiaalaappkaaiaaaaad
acaaaboaabaaoejaaaaaoeiaaiaaaaadacaaacoaabaaoeiaaaaaoeiaaiaaaaad
acaaaeoaacaaoejaaaaaoeiaabaaaaacaaaaabiaahaakkkaabaaaaacaaaaacia
aiaakkkaabaaaaacaaaaaeiaajaakkkaafaaaaadaaaaahiaaaaaoeiaalaappka
aiaaaaadadaaaboaabaaoejaaaaaoeiaaiaaaaadadaaacoaabaaoeiaaaaaoeia
aiaaaaadadaaaeoaacaaoejaaaaaoeiaafaaaaadaaaaapiaaaaaffjaaeaaoeka
aeaaaaaeaaaaapiaadaaoekaaaaaaajaaaaaoeiaaeaaaaaeaaaaapiaafaaoeka
aaaakkjaaaaaoeiaaeaaaaaeaaaaapiaagaaoekaaaaappjaaaaaoeiaaeaaaaae
aaaaadmaaaaappiaaaaaoekaaaaaoeiaabaaaaacaaaaammaaaaaoeiaabaaaaac
aaaaamoaamaaaakappppaaaafdeieefceaafaaaaeaaaabaafaabaaaafjaaaaae
egiocaaaaaaaaaaaaeaaaaaafjaaaaaeegiocaaaabaaaaaaafaaaaaafjaaaaae
egiocaaaacaaaaaabfaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaadpcbabaaa
abaaaaaafpaaaaadhcbabaaaacaaaaaafpaaaaaddcbabaaaadaaaaaaghaaaaae
pccabaaaaaaaaaaaabaaaaaagfaaaaadpccabaaaabaaaaaagfaaaaadhccabaaa
acaaaaaagfaaaaadhccabaaaadaaaaaagfaaaaadhccabaaaaeaaaaaagfaaaaad
hccabaaaafaaaaaagiaaaaacacaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaa
aaaaaaaaegiocaaaacaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaa
acaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaa
aaaaaaaaegiocaaaacaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaa
dcaaaaakpccabaaaaaaaaaaaegiocaaaacaaaaaaadaaaaaapgbpbaaaaaaaaaaa
egaobaaaaaaaaaaadcaaaaaldccabaaaabaaaaaaegbabaaaadaaaaaaegiacaaa
aaaaaaaaadaaaaaaogikcaaaaaaaaaaaadaaaaaadgaaaaaimccabaaaabaaaaaa
aceaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaadgaaaaagbcaabaaaaaaaaaaa
akiacaaaacaaaaaaamaaaaaadgaaaaagccaabaaaaaaaaaaaakiacaaaacaaaaaa
anaaaaaadgaaaaagecaabaaaaaaaaaaaakiacaaaacaaaaaaaoaaaaaadiaaaaai
hcaabaaaaaaaaaaaegacbaaaaaaaaaaapgipcaaaacaaaaaabeaaaaaabaaaaaah
bccabaaaacaaaaaaegbcbaaaabaaaaaaegacbaaaaaaaaaaabaaaaaaheccabaaa
acaaaaaaegbcbaaaacaaaaaaegacbaaaaaaaaaaadiaaaaahhcaabaaaabaaaaaa
jgbebaaaabaaaaaacgbjbaaaacaaaaaadcaaaaakhcaabaaaabaaaaaajgbebaaa
acaaaaaacgbjbaaaabaaaaaaegacbaiaebaaaaaaabaaaaaadiaaaaahhcaabaaa
abaaaaaaegacbaaaabaaaaaapgbpbaaaabaaaaaabaaaaaahcccabaaaacaaaaaa
egacbaaaabaaaaaaegacbaaaaaaaaaaadgaaaaagbcaabaaaaaaaaaaabkiacaaa
acaaaaaaamaaaaaadgaaaaagccaabaaaaaaaaaaabkiacaaaacaaaaaaanaaaaaa
dgaaaaagecaabaaaaaaaaaaabkiacaaaacaaaaaaaoaaaaaadiaaaaaihcaabaaa
aaaaaaaaegacbaaaaaaaaaaapgipcaaaacaaaaaabeaaaaaabaaaaaahcccabaaa
adaaaaaaegacbaaaabaaaaaaegacbaaaaaaaaaaabaaaaaahbccabaaaadaaaaaa
egbcbaaaabaaaaaaegacbaaaaaaaaaaabaaaaaaheccabaaaadaaaaaaegbcbaaa
acaaaaaaegacbaaaaaaaaaaadgaaaaagbcaabaaaaaaaaaaackiacaaaacaaaaaa
amaaaaaadgaaaaagccaabaaaaaaaaaaackiacaaaacaaaaaaanaaaaaadgaaaaag
ecaabaaaaaaaaaaackiacaaaacaaaaaaaoaaaaaadiaaaaaihcaabaaaaaaaaaaa
egacbaaaaaaaaaaapgipcaaaacaaaaaabeaaaaaabaaaaaahcccabaaaaeaaaaaa
egacbaaaabaaaaaaegacbaaaaaaaaaaabaaaaaahbccabaaaaeaaaaaaegbcbaaa
abaaaaaaegacbaaaaaaaaaaabaaaaaaheccabaaaaeaaaaaaegbcbaaaacaaaaaa
egacbaaaaaaaaaaadiaaaaaihcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiccaaa
acaaaaaaanaaaaaadcaaaaakhcaabaaaaaaaaaaaegiccaaaacaaaaaaamaaaaaa
agbabaaaaaaaaaaaegacbaaaaaaaaaaadcaaaaakhcaabaaaaaaaaaaaegiccaaa
acaaaaaaaoaaaaaakgbkbaaaaaaaaaaaegacbaaaaaaaaaaadcaaaaakhcaabaaa
aaaaaaaaegiccaaaacaaaaaaapaaaaaapgbpbaaaaaaaaaaaegacbaaaaaaaaaaa
aaaaaaajhcaabaaaaaaaaaaaegacbaiaebaaaaaaaaaaaaaaegiccaaaabaaaaaa
aeaaaaaabaaaaaahicaabaaaaaaaaaaaegacbaaaaaaaaaaaegacbaaaaaaaaaaa
eeaaaaaficaabaaaaaaaaaaadkaabaaaaaaaaaaadiaaaaahhccabaaaafaaaaaa
pgapbaaaaaaaaaaaegacbaaaaaaaaaaadoaaaaabejfdeheomaaaaaaaagaaaaaa
aiaaaaaajiaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaakbaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapapaaaakjaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaacaaaaaaahahaaaalaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaadaaaaaa
apadaaaalaaaaaaaabaaaaaaaaaaaaaaadaaaaaaaeaaaaaaapaaaaaaljaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaafaaaaaaapaaaaaafaepfdejfeejepeoaafeebeo
ehefeofeaaeoepfcenebemaafeeffiedepepfceeaaedepemepfcaaklepfdeheo
laaaaaaaagaaaaaaaiaaaaaajiaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaa
apaaaaaakeaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapaaaaaakeaaaaaa
acaaaaaaaaaaaaaaadaaaaaaacaaaaaaahaiaaaakeaaaaaaadaaaaaaaaaaaaaa
adaaaaaaadaaaaaaahaiaaaakeaaaaaaaeaaaaaaaaaaaaaaadaaaaaaaeaaaaaa
ahaiaaaakeaaaaaaafaaaaaaaaaaaaaaadaaaaaaafaaaaaaahaiaaaafdfgfpfa
epfdejfeejepeoaafeeffiedepepfceeaaklklkl"
}

SubProgram "gles3 " {
Keywords { "LIGHTMAP_OFF" }
"!!GLES3#version 300 es


#ifdef VERTEX

#define gl_Vertex _glesVertex
in vec4 _glesVertex;
#define gl_Color _glesColor
in vec4 _glesColor;
#define gl_Normal (normalize(_glesNormal))
in vec3 _glesNormal;
#define gl_MultiTexCoord0 _glesMultiTexCoord0
in vec4 _glesMultiTexCoord0;
#define gl_MultiTexCoord1 _glesMultiTexCoord1
in vec4 _glesMultiTexCoord1;
#define TANGENT vec4(normalize(_glesTANGENT.xyz), _glesTANGENT.w)
in vec4 _glesTANGENT;
mat2 xll_transpose_mf2x2(mat2 m) {
  return mat2( m[0][0], m[1][0], m[0][1], m[1][1]);
}
mat3 xll_transpose_mf3x3(mat3 m) {
  return mat3( m[0][0], m[1][0], m[2][0],
               m[0][1], m[1][1], m[2][1],
               m[0][2], m[1][2], m[2][2]);
}
mat4 xll_transpose_mf4x4(mat4 m) {
  return mat4( m[0][0], m[1][0], m[2][0], m[3][0],
               m[0][1], m[1][1], m[2][1], m[3][1],
               m[0][2], m[1][2], m[2][2], m[3][2],
               m[0][3], m[1][3], m[2][3], m[3][3]);
}
vec2 xll_matrixindex_mf2x2_i (mat2 m, int i) { vec2 v; v.x=m[0][i]; v.y=m[1][i]; return v; }
vec3 xll_matrixindex_mf3x3_i (mat3 m, int i) { vec3 v; v.x=m[0][i]; v.y=m[1][i]; v.z=m[2][i]; return v; }
vec4 xll_matrixindex_mf4x4_i (mat4 m, int i) { vec4 v; v.x=m[0][i]; v.y=m[1][i]; v.z=m[2][i]; v.w=m[3][i]; return v; }
#line 167
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 203
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 197
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 83
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
#line 57
struct v2f_full {
    highp vec4 pos;
    mediump vec4 uv;
    mediump vec3 tsBase0;
    mediump vec3 tsBase1;
    mediump vec3 tsBase2;
    mediump vec3 viewDir;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform highp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 67
uniform lowp vec4 unity_ColorSpaceGrey;
#line 93
#line 98
#line 103
#line 107
#line 112
#line 136
#line 153
#line 174
#line 182
#line 209
#line 222
#line 231
#line 236
#line 245
#line 250
#line 259
#line 276
#line 281
#line 307
#line 315
#line 323
#line 327
#line 331
uniform sampler2D _MainTex;
uniform sampler2D _Normal;
uniform samplerCube _Cube;
uniform mediump float _OneMinusReflectivity;
#line 335
#line 343
uniform highp vec4 unity_LightmapST;
uniform sampler2D unity_Lightmap;
#line 351
uniform highp vec4 _MainTex_ST;
#line 103
highp vec3 WorldSpaceViewDir( in highp vec4 v ) {
    return (_WorldSpaceCameraPos.xyz - (_Object2World * v).xyz);
}
#line 335
void WriteTangentSpaceData( in appdata_full v, out mediump vec3 ts0, out mediump vec3 ts1, out mediump vec3 ts2 ) {
    highp vec3 binormal = (cross( v.normal, v.tangent.xyz) * v.tangent.w);
    highp mat3 rotation = xll_transpose_mf3x3(mat3( v.tangent.xyz, binormal, v.normal));
    #line 339
    ts0 = (rotation * (xll_matrixindex_mf4x4_i (_Object2World, 0).xyz * unity_Scale.w));
    ts1 = (rotation * (xll_matrixindex_mf4x4_i (_Object2World, 1).xyz * unity_Scale.w));
    ts2 = (rotation * (xll_matrixindex_mf4x4_i (_Object2World, 2).xyz * unity_Scale.w));
}
#line 352
v2f_full vert( in appdata_full v ) {
    v2f_full o;
    #line 355
    o.pos = (glstate_matrix_mvp * v.vertex);
    o.uv.xy = ((v.texcoord.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
    o.uv.zw = vec2( 0.0, 0.0);
    o.viewDir = normalize(WorldSpaceViewDir( v.vertex));
    #line 359
    WriteTangentSpaceData( v, o.tsBase0, o.tsBase1, o.tsBase2);
    return o;
}

out mediump vec4 xlv_TEXCOORD0;
out mediump vec3 xlv_TEXCOORD2;
out mediump vec3 xlv_TEXCOORD3;
out mediump vec3 xlv_TEXCOORD4;
out mediump vec3 xlv_TEXCOORD5;
void main() {
    v2f_full xl_retval;
    appdata_full xlt_v;
    xlt_v.vertex = vec4(gl_Vertex);
    xlt_v.tangent = vec4(TANGENT);
    xlt_v.normal = vec3(gl_Normal);
    xlt_v.texcoord = vec4(gl_MultiTexCoord0);
    xlt_v.texcoord1 = vec4(gl_MultiTexCoord1);
    xlt_v.color = vec4(gl_Color);
    xl_retval = vert( xlt_v);
    gl_Position = vec4(xl_retval.pos);
    xlv_TEXCOORD0 = vec4(xl_retval.uv);
    xlv_TEXCOORD2 = vec3(xl_retval.tsBase0);
    xlv_TEXCOORD3 = vec3(xl_retval.tsBase1);
    xlv_TEXCOORD4 = vec3(xl_retval.tsBase2);
    xlv_TEXCOORD5 = vec3(xl_retval.viewDir);
}


#endif
#ifdef FRAGMENT

#define gl_FragData _glesFragData
layout(location = 0) out mediump vec4 _glesFragData[4];
float xll_saturate_f( float x) {
  return clamp( x, 0.0, 1.0);
}
vec2 xll_saturate_vf2( vec2 x) {
  return clamp( x, 0.0, 1.0);
}
vec3 xll_saturate_vf3( vec3 x) {
  return clamp( x, 0.0, 1.0);
}
vec4 xll_saturate_vf4( vec4 x) {
  return clamp( x, 0.0, 1.0);
}
mat2 xll_saturate_mf2x2(mat2 m) {
  return mat2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));
}
mat3 xll_saturate_mf3x3(mat3 m) {
  return mat3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));
}
mat4 xll_saturate_mf4x4(mat4 m) {
  return mat4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));
}
#line 167
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 203
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 197
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 83
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
#line 57
struct v2f_full {
    highp vec4 pos;
    mediump vec4 uv;
    mediump vec3 tsBase0;
    mediump vec3 tsBase1;
    mediump vec3 tsBase2;
    mediump vec3 viewDir;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform highp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 67
uniform lowp vec4 unity_ColorSpaceGrey;
#line 93
#line 98
#line 103
#line 107
#line 112
#line 136
#line 153
#line 174
#line 182
#line 209
#line 222
#line 231
#line 236
#line 245
#line 250
#line 259
#line 276
#line 281
#line 307
#line 315
#line 323
#line 327
#line 331
uniform sampler2D _MainTex;
uniform sampler2D _Normal;
uniform samplerCube _Cube;
uniform mediump float _OneMinusReflectivity;
#line 335
#line 343
uniform highp vec4 unity_LightmapST;
uniform sampler2D unity_Lightmap;
#line 351
uniform highp vec4 _MainTex_ST;
#line 288
lowp vec3 UnpackNormal( in lowp vec4 packednormal ) {
    #line 290
    return ((packednormal.xyz * 2.0) - 1.0);
}
#line 362
lowp vec4 frag( in v2f_full i ) {
    #line 364
    mediump vec3 nrml = UnpackNormal( texture( _Normal, i.uv.xy));
    mediump vec3 bumpedNormal = vec3( dot( i.tsBase0, nrml), dot( i.tsBase1, nrml), dot( i.tsBase2, nrml));
    bumpedNormal = ((bumpedNormal + i.viewDir.xyz) * 0.5);
    lowp vec4 tex = texture( _MainTex, i.uv.xy);
    #line 368
    mediump vec3 reflectVector = reflect( (-i.viewDir.xyz), bumpedNormal.xyz);
    lowp vec4 reflection = texture( _Cube, reflectVector);
    tex += (reflection * xll_saturate_f((tex.w - _OneMinusReflectivity)));
    tex.xyz *= 0.75;
    #line 372
    return tex;
}
in mediump vec4 xlv_TEXCOORD0;
in mediump vec3 xlv_TEXCOORD2;
in mediump vec3 xlv_TEXCOORD3;
in mediump vec3 xlv_TEXCOORD4;
in mediump vec3 xlv_TEXCOORD5;
void main() {
    lowp vec4 xl_retval;
    v2f_full xlt_i;
    xlt_i.pos = vec4(0.0);
    xlt_i.uv = vec4(xlv_TEXCOORD0);
    xlt_i.tsBase0 = vec3(xlv_TEXCOORD2);
    xlt_i.tsBase1 = vec3(xlv_TEXCOORD3);
    xlt_i.tsBase2 = vec3(xlv_TEXCOORD4);
    xlt_i.viewDir = vec3(xlv_TEXCOORD5);
    xl_retval = frag( xlt_i);
    gl_FragData[0] = vec4(xl_retval);
}


#endif"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" }
Bind "vertex" Vertex
Bind "tangent" ATTR14
Bind "normal" Normal
Bind "texcoord" TexCoord0
Bind "texcoord1" TexCoord1
Vector 9 [_WorldSpaceCameraPos]
Matrix 5 [_Object2World]
Vector 10 [unity_Scale]
Vector 11 [unity_LightmapST]
Vector 12 [_MainTex_ST]
"!!ARBvp1.0
# 30 ALU
PARAM c[13] = { program.local[0],
		state.matrix.mvp,
		program.local[5..12] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
MOV R1.w, c[10];
MUL R2.xyz, R1.w, c[5];
MUL R3.xyz, R1.w, c[6];
MUL R4.xyz, R1.w, c[7];
MOV R0.xyz, vertex.attrib[14];
MUL R1.xyz, vertex.normal.zxyw, R0.yzxw;
MAD R0.xyz, vertex.normal.yzxw, R0.zxyw, -R1;
MUL R1.xyz, R0, vertex.attrib[14].w;
DP4 R0.z, vertex.position, c[7];
DP4 R0.x, vertex.position, c[5];
DP4 R0.y, vertex.position, c[6];
ADD R0.xyz, -R0, c[9];
DP3 R0.w, R0, R0;
RSQ R0.w, R0.w;
DP3 result.texcoord[2].y, R2, R1;
DP3 result.texcoord[3].y, R1, R3;
DP3 result.texcoord[4].y, R1, R4;
MUL result.texcoord[5].xyz, R0.w, R0;
DP3 result.texcoord[2].z, vertex.normal, R2;
DP3 result.texcoord[2].x, R2, vertex.attrib[14];
DP3 result.texcoord[3].z, vertex.normal, R3;
DP3 result.texcoord[3].x, vertex.attrib[14], R3;
DP3 result.texcoord[4].z, vertex.normal, R4;
DP3 result.texcoord[4].x, vertex.attrib[14], R4;
MAD result.texcoord[0].zw, vertex.texcoord[1].xyxy, c[11].xyxy, c[11];
MAD result.texcoord[0].xy, vertex.texcoord[0], c[12], c[12].zwzw;
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 30 instructions, 5 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord" TexCoord0
Bind "texcoord1" TexCoord1
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Matrix 4 [_Object2World]
Vector 9 [unity_Scale]
Vector 10 [unity_LightmapST]
Vector 11 [_MainTex_ST]
"vs_2_0
; 33 ALU
dcl_position0 v0
dcl_tangent0 v1
dcl_normal0 v2
dcl_texcoord0 v3
dcl_texcoord1 v4
mov r0.xyz, v1
mul r1.xyz, v2.zxyw, r0.yzxw
mov r0.xyz, v1
mad r0.xyz, v2.yzxw, r0.zxyw, -r1
mul r2.xyz, r0, v1.w
mov r0.xyz, c4
mul r3.xyz, c9.w, r0
mov r1.xyz, c5
mul r4.xyz, c9.w, r1
dp4 r0.z, v0, c6
dp4 r0.x, v0, c4
dp4 r0.y, v0, c5
add r1.xyz, -r0, c8
mov r0.xyz, c6
mul r0.xyz, c9.w, r0
dp3 r0.w, r1, r1
rsq r0.w, r0.w
dp3 oT2.y, r3, r2
dp3 oT3.y, r2, r4
dp3 oT4.y, r2, r0
mul oT5.xyz, r0.w, r1
dp3 oT2.z, v2, r3
dp3 oT2.x, r3, v1
dp3 oT3.z, v2, r4
dp3 oT3.x, v1, r4
dp3 oT4.z, v2, r0
dp3 oT4.x, v1, r0
mad oT0.zw, v4.xyxy, c10.xyxy, c10
mad oT0.xy, v3, c11, c11.zwzw
dp4 oPos.w, v0, c3
dp4 oPos.z, v0, c2
dp4 oPos.y, v0, c1
dp4 oPos.x, v0, c0
"
}

SubProgram "d3d11 " {
Keywords { "LIGHTMAP_ON" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord" TexCoord0
Bind "texcoord1" TexCoord1
Bind "color" Color
ConstBuffer "$Globals" 64 // 64 used size, 4 vars
Vector 32 [unity_LightmapST] 4
Vector 48 [_MainTex_ST] 4
ConstBuffer "UnityPerCamera" 128 // 76 used size, 8 vars
Vector 64 [_WorldSpaceCameraPos] 3
ConstBuffer "UnityPerDraw" 336 // 336 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
Matrix 192 [_Object2World] 4
Vector 320 [unity_Scale] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
BindCB "UnityPerDraw" 2
// 39 instructions, 2 temp regs, 0 temp arrays:
// ALU 29 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0
eefiecedholegebmpbdmllanobnolfjkllkaaabfabaaaaaaamahaaaaadaaaaaa
cmaaaaaapeaaaaaakmabaaaaejfdeheomaaaaaaaagaaaaaaaiaaaaaajiaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaakbaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaakjaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
ahahaaaalaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaadaaaaaaapadaaaalaaaaaaa
abaaaaaaaaaaaaaaadaaaaaaaeaaaaaaapadaaaaljaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaafaaaaaaapaaaaaafaepfdejfeejepeoaafeebeoehefeofeaaeoepfc
enebemaafeeffiedepepfceeaaedepemepfcaaklepfdeheolaaaaaaaagaaaaaa
aiaaaaaajiaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaakeaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapaaaaaakeaaaaaaacaaaaaaaaaaaaaa
adaaaaaaacaaaaaaahaiaaaakeaaaaaaadaaaaaaaaaaaaaaadaaaaaaadaaaaaa
ahaiaaaakeaaaaaaaeaaaaaaaaaaaaaaadaaaaaaaeaaaaaaahaiaaaakeaaaaaa
afaaaaaaaaaaaaaaadaaaaaaafaaaaaaahaiaaaafdfgfpfaepfdejfeejepeoaa
feeffiedepepfceeaaklklklfdeieefcfiafaaaaeaaaabaafgabaaaafjaaaaae
egiocaaaaaaaaaaaaeaaaaaafjaaaaaeegiocaaaabaaaaaaafaaaaaafjaaaaae
egiocaaaacaaaaaabfaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaadpcbabaaa
abaaaaaafpaaaaadhcbabaaaacaaaaaafpaaaaaddcbabaaaadaaaaaafpaaaaad
dcbabaaaaeaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaadpccabaaa
abaaaaaagfaaaaadhccabaaaacaaaaaagfaaaaadhccabaaaadaaaaaagfaaaaad
hccabaaaaeaaaaaagfaaaaadhccabaaaafaaaaaagiaaaaacacaaaaaadiaaaaai
pcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaaacaaaaaaabaaaaaadcaaaaak
pcaabaaaaaaaaaaaegiocaaaacaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaa
aaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaaacaaaaaakgbkbaaa
aaaaaaaaegaobaaaaaaaaaaadcaaaaakpccabaaaaaaaaaaaegiocaaaacaaaaaa
adaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaaldccabaaaabaaaaaa
egbabaaaadaaaaaaegiacaaaaaaaaaaaadaaaaaaogikcaaaaaaaaaaaadaaaaaa
dcaaaaalmccabaaaabaaaaaaagbebaaaaeaaaaaaagiecaaaaaaaaaaaacaaaaaa
kgiocaaaaaaaaaaaacaaaaaadgaaaaagbcaabaaaaaaaaaaaakiacaaaacaaaaaa
amaaaaaadgaaaaagccaabaaaaaaaaaaaakiacaaaacaaaaaaanaaaaaadgaaaaag
ecaabaaaaaaaaaaaakiacaaaacaaaaaaaoaaaaaadiaaaaaihcaabaaaaaaaaaaa
egacbaaaaaaaaaaapgipcaaaacaaaaaabeaaaaaabaaaaaahbccabaaaacaaaaaa
egbcbaaaabaaaaaaegacbaaaaaaaaaaabaaaaaaheccabaaaacaaaaaaegbcbaaa
acaaaaaaegacbaaaaaaaaaaadiaaaaahhcaabaaaabaaaaaajgbebaaaabaaaaaa
cgbjbaaaacaaaaaadcaaaaakhcaabaaaabaaaaaajgbebaaaacaaaaaacgbjbaaa
abaaaaaaegacbaiaebaaaaaaabaaaaaadiaaaaahhcaabaaaabaaaaaaegacbaaa
abaaaaaapgbpbaaaabaaaaaabaaaaaahcccabaaaacaaaaaaegacbaaaabaaaaaa
egacbaaaaaaaaaaadgaaaaagbcaabaaaaaaaaaaabkiacaaaacaaaaaaamaaaaaa
dgaaaaagccaabaaaaaaaaaaabkiacaaaacaaaaaaanaaaaaadgaaaaagecaabaaa
aaaaaaaabkiacaaaacaaaaaaaoaaaaaadiaaaaaihcaabaaaaaaaaaaaegacbaaa
aaaaaaaapgipcaaaacaaaaaabeaaaaaabaaaaaahcccabaaaadaaaaaaegacbaaa
abaaaaaaegacbaaaaaaaaaaabaaaaaahbccabaaaadaaaaaaegbcbaaaabaaaaaa
egacbaaaaaaaaaaabaaaaaaheccabaaaadaaaaaaegbcbaaaacaaaaaaegacbaaa
aaaaaaaadgaaaaagbcaabaaaaaaaaaaackiacaaaacaaaaaaamaaaaaadgaaaaag
ccaabaaaaaaaaaaackiacaaaacaaaaaaanaaaaaadgaaaaagecaabaaaaaaaaaaa
ckiacaaaacaaaaaaaoaaaaaadiaaaaaihcaabaaaaaaaaaaaegacbaaaaaaaaaaa
pgipcaaaacaaaaaabeaaaaaabaaaaaahcccabaaaaeaaaaaaegacbaaaabaaaaaa
egacbaaaaaaaaaaabaaaaaahbccabaaaaeaaaaaaegbcbaaaabaaaaaaegacbaaa
aaaaaaaabaaaaaaheccabaaaaeaaaaaaegbcbaaaacaaaaaaegacbaaaaaaaaaaa
diaaaaaihcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiccaaaacaaaaaaanaaaaaa
dcaaaaakhcaabaaaaaaaaaaaegiccaaaacaaaaaaamaaaaaaagbabaaaaaaaaaaa
egacbaaaaaaaaaaadcaaaaakhcaabaaaaaaaaaaaegiccaaaacaaaaaaaoaaaaaa
kgbkbaaaaaaaaaaaegacbaaaaaaaaaaadcaaaaakhcaabaaaaaaaaaaaegiccaaa
acaaaaaaapaaaaaapgbpbaaaaaaaaaaaegacbaaaaaaaaaaaaaaaaaajhcaabaaa
aaaaaaaaegacbaiaebaaaaaaaaaaaaaaegiccaaaabaaaaaaaeaaaaaabaaaaaah
icaabaaaaaaaaaaaegacbaaaaaaaaaaaegacbaaaaaaaaaaaeeaaaaaficaabaaa
aaaaaaaadkaabaaaaaaaaaaadiaaaaahhccabaaaafaaaaaapgapbaaaaaaaaaaa
egacbaaaaaaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" }
"!!GLES


#ifdef VERTEX

varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying mediump vec3 xlv_TEXCOORD2;
varying mediump vec4 xlv_TEXCOORD0;
uniform highp vec4 _MainTex_ST;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec4 _glesMultiTexCoord1;
attribute vec4 _glesMultiTexCoord0;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  mediump vec4 tmpvar_3;
  mediump vec3 tmpvar_4;
  highp vec2 tmpvar_5;
  tmpvar_5 = ((_glesMultiTexCoord0.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
  tmpvar_3.xy = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  tmpvar_3.zw = tmpvar_6;
  highp vec3 tmpvar_7;
  tmpvar_7 = normalize((_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz));
  tmpvar_4 = tmpvar_7;
  mediump vec3 ts0_8;
  mediump vec3 ts1_9;
  mediump vec3 ts2_10;
  highp vec3 tmpvar_11;
  highp vec3 tmpvar_12;
  tmpvar_11 = tmpvar_1.xyz;
  tmpvar_12 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_13;
  tmpvar_13[0].x = tmpvar_11.x;
  tmpvar_13[0].y = tmpvar_12.x;
  tmpvar_13[0].z = tmpvar_2.x;
  tmpvar_13[1].x = tmpvar_11.y;
  tmpvar_13[1].y = tmpvar_12.y;
  tmpvar_13[1].z = tmpvar_2.y;
  tmpvar_13[2].x = tmpvar_11.z;
  tmpvar_13[2].y = tmpvar_12.z;
  tmpvar_13[2].z = tmpvar_2.z;
  vec4 v_14;
  v_14.x = _Object2World[0].x;
  v_14.y = _Object2World[1].x;
  v_14.z = _Object2World[2].x;
  v_14.w = _Object2World[3].x;
  highp vec3 tmpvar_15;
  tmpvar_15 = (tmpvar_13 * (v_14.xyz * unity_Scale.w));
  ts0_8 = tmpvar_15;
  vec4 v_16;
  v_16.x = _Object2World[0].y;
  v_16.y = _Object2World[1].y;
  v_16.z = _Object2World[2].y;
  v_16.w = _Object2World[3].y;
  highp vec3 tmpvar_17;
  tmpvar_17 = (tmpvar_13 * (v_16.xyz * unity_Scale.w));
  ts1_9 = tmpvar_17;
  vec4 v_18;
  v_18.x = _Object2World[0].z;
  v_18.y = _Object2World[1].z;
  v_18.z = _Object2World[2].z;
  v_18.w = _Object2World[3].z;
  highp vec3 tmpvar_19;
  tmpvar_19 = (tmpvar_13 * (v_18.xyz * unity_Scale.w));
  ts2_10 = tmpvar_19;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_3;
  xlv_TEXCOORD2 = ts0_8;
  xlv_TEXCOORD3 = ts1_9;
  xlv_TEXCOORD4 = ts2_10;
  xlv_TEXCOORD5 = tmpvar_4;
}



#endif
#ifdef FRAGMENT

varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying mediump vec3 xlv_TEXCOORD2;
varying mediump vec4 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform mediump float _OneMinusReflectivity;
uniform samplerCube _Cube;
uniform sampler2D _Normal;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tex_1;
  mediump vec3 nrml_2;
  lowp vec3 tmpvar_3;
  tmpvar_3 = ((texture2D (_Normal, xlv_TEXCOORD0.xy).xyz * 2.0) - 1.0);
  nrml_2 = tmpvar_3;
  mediump vec3 tmpvar_4;
  tmpvar_4.x = dot (xlv_TEXCOORD2, nrml_2);
  tmpvar_4.y = dot (xlv_TEXCOORD3, nrml_2);
  tmpvar_4.z = dot (xlv_TEXCOORD4, nrml_2);
  mediump vec3 tmpvar_5;
  tmpvar_5 = ((tmpvar_4 + xlv_TEXCOORD5) * 0.5);
  lowp vec4 tmpvar_6;
  tmpvar_6 = texture2D (_MainTex, xlv_TEXCOORD0.xy);
  mediump vec3 tmpvar_7;
  mediump vec3 i_8;
  i_8 = -(xlv_TEXCOORD5);
  tmpvar_7 = (i_8 - (2.0 * (dot (tmpvar_5, i_8) * tmpvar_5)));
  mediump float tmpvar_9;
  tmpvar_9 = clamp ((tmpvar_6.w - _OneMinusReflectivity), 0.0, 1.0);
  lowp vec4 tmpvar_10;
  tmpvar_10 = (tmpvar_6 + (textureCube (_Cube, tmpvar_7) * tmpvar_9));
  tex_1.w = tmpvar_10.w;
  tex_1.xyz = (tmpvar_10.xyz * (2.0 * texture2D (unity_Lightmap, xlv_TEXCOORD0.zw).xyz));
  gl_FragData[0] = tex_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" }
"!!GLES


#ifdef VERTEX

varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying mediump vec3 xlv_TEXCOORD2;
varying mediump vec4 xlv_TEXCOORD0;
uniform highp vec4 _MainTex_ST;
uniform highp vec4 unity_LightmapST;
uniform highp vec4 unity_Scale;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec4 _glesMultiTexCoord1;
attribute vec4 _glesMultiTexCoord0;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  mediump vec4 tmpvar_3;
  mediump vec3 tmpvar_4;
  highp vec2 tmpvar_5;
  tmpvar_5 = ((_glesMultiTexCoord0.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
  tmpvar_3.xy = tmpvar_5;
  highp vec2 tmpvar_6;
  tmpvar_6 = ((_glesMultiTexCoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
  tmpvar_3.zw = tmpvar_6;
  highp vec3 tmpvar_7;
  tmpvar_7 = normalize((_WorldSpaceCameraPos - (_Object2World * _glesVertex).xyz));
  tmpvar_4 = tmpvar_7;
  mediump vec3 ts0_8;
  mediump vec3 ts1_9;
  mediump vec3 ts2_10;
  highp vec3 tmpvar_11;
  highp vec3 tmpvar_12;
  tmpvar_11 = tmpvar_1.xyz;
  tmpvar_12 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_13;
  tmpvar_13[0].x = tmpvar_11.x;
  tmpvar_13[0].y = tmpvar_12.x;
  tmpvar_13[0].z = tmpvar_2.x;
  tmpvar_13[1].x = tmpvar_11.y;
  tmpvar_13[1].y = tmpvar_12.y;
  tmpvar_13[1].z = tmpvar_2.y;
  tmpvar_13[2].x = tmpvar_11.z;
  tmpvar_13[2].y = tmpvar_12.z;
  tmpvar_13[2].z = tmpvar_2.z;
  vec4 v_14;
  v_14.x = _Object2World[0].x;
  v_14.y = _Object2World[1].x;
  v_14.z = _Object2World[2].x;
  v_14.w = _Object2World[3].x;
  highp vec3 tmpvar_15;
  tmpvar_15 = (tmpvar_13 * (v_14.xyz * unity_Scale.w));
  ts0_8 = tmpvar_15;
  vec4 v_16;
  v_16.x = _Object2World[0].y;
  v_16.y = _Object2World[1].y;
  v_16.z = _Object2World[2].y;
  v_16.w = _Object2World[3].y;
  highp vec3 tmpvar_17;
  tmpvar_17 = (tmpvar_13 * (v_16.xyz * unity_Scale.w));
  ts1_9 = tmpvar_17;
  vec4 v_18;
  v_18.x = _Object2World[0].z;
  v_18.y = _Object2World[1].z;
  v_18.z = _Object2World[2].z;
  v_18.w = _Object2World[3].z;
  highp vec3 tmpvar_19;
  tmpvar_19 = (tmpvar_13 * (v_18.xyz * unity_Scale.w));
  ts2_10 = tmpvar_19;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_3;
  xlv_TEXCOORD2 = ts0_8;
  xlv_TEXCOORD3 = ts1_9;
  xlv_TEXCOORD4 = ts2_10;
  xlv_TEXCOORD5 = tmpvar_4;
}



#endif
#ifdef FRAGMENT

varying mediump vec3 xlv_TEXCOORD5;
varying mediump vec3 xlv_TEXCOORD4;
varying mediump vec3 xlv_TEXCOORD3;
varying mediump vec3 xlv_TEXCOORD2;
varying mediump vec4 xlv_TEXCOORD0;
uniform sampler2D unity_Lightmap;
uniform mediump float _OneMinusReflectivity;
uniform samplerCube _Cube;
uniform sampler2D _Normal;
uniform sampler2D _MainTex;
void main ()
{
  lowp vec4 tex_1;
  mediump vec3 nrml_2;
  lowp vec3 normal_3;
  normal_3.xy = ((texture2D (_Normal, xlv_TEXCOORD0.xy).wy * 2.0) - 1.0);
  normal_3.z = sqrt((1.0 - clamp (dot (normal_3.xy, normal_3.xy), 0.0, 1.0)));
  nrml_2 = normal_3;
  mediump vec3 tmpvar_4;
  tmpvar_4.x = dot (xlv_TEXCOORD2, nrml_2);
  tmpvar_4.y = dot (xlv_TEXCOORD3, nrml_2);
  tmpvar_4.z = dot (xlv_TEXCOORD4, nrml_2);
  mediump vec3 tmpvar_5;
  tmpvar_5 = ((tmpvar_4 + xlv_TEXCOORD5) * 0.5);
  lowp vec4 tmpvar_6;
  tmpvar_6 = texture2D (_MainTex, xlv_TEXCOORD0.xy);
  mediump vec3 tmpvar_7;
  mediump vec3 i_8;
  i_8 = -(xlv_TEXCOORD5);
  tmpvar_7 = (i_8 - (2.0 * (dot (tmpvar_5, i_8) * tmpvar_5)));
  mediump float tmpvar_9;
  tmpvar_9 = clamp ((tmpvar_6.w - _OneMinusReflectivity), 0.0, 1.0);
  lowp vec4 tmpvar_10;
  tmpvar_10 = (tmpvar_6 + (textureCube (_Cube, tmpvar_7) * tmpvar_9));
  tex_1.w = tmpvar_10.w;
  lowp vec4 tmpvar_11;
  tmpvar_11 = texture2D (unity_Lightmap, xlv_TEXCOORD0.zw);
  tex_1.xyz = (tmpvar_10.xyz * ((8.0 * tmpvar_11.w) * tmpvar_11.xyz));
  gl_FragData[0] = tex_1;
}



#endif"
}

SubProgram "flash " {
Keywords { "LIGHTMAP_ON" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord" TexCoord0
Bind "texcoord1" TexCoord1
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Matrix 4 [_Object2World]
Vector 9 [unity_Scale]
Vector 10 [unity_LightmapST]
Vector 11 [_MainTex_ST]
"agal_vs
[bc]
aaaaaaaaaaaaahacafaaaaoeaaaaaaaaaaaaaaaaaaaaaaaa mov r0.xyz, a5
adaaaaaaabaaahacabaaaancaaaaaaaaaaaaaaajacaaaaaa mul r1.xyz, a1.zxyw, r0.yzxx
aaaaaaaaaaaaahacafaaaaoeaaaaaaaaaaaaaaaaaaaaaaaa mov r0.xyz, a5
adaaaaaaacaaahacabaaaamjaaaaaaaaaaaaaafcacaaaaaa mul r2.xyz, a1.yzxw, r0.zxyy
acaaaaaaaaaaahacacaaaakeacaaaaaaabaaaakeacaaaaaa sub r0.xyz, r2.xyzz, r1.xyzz
adaaaaaaacaaahacaaaaaakeacaaaaaaafaaaappaaaaaaaa mul r2.xyz, r0.xyzz, a5.w
aaaaaaaaaaaaahacaeaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r0.xyz, c4
adaaaaaaadaaahacajaaaappabaaaaaaaaaaaakeacaaaaaa mul r3.xyz, c9.w, r0.xyzz
aaaaaaaaabaaahacafaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r1.xyz, c5
adaaaaaaaeaaahacajaaaappabaaaaaaabaaaakeacaaaaaa mul r4.xyz, c9.w, r1.xyzz
bdaaaaaaaaaaaeacaaaaaaoeaaaaaaaaagaaaaoeabaaaaaa dp4 r0.z, a0, c6
bdaaaaaaaaaaabacaaaaaaoeaaaaaaaaaeaaaaoeabaaaaaa dp4 r0.x, a0, c4
bdaaaaaaaaaaacacaaaaaaoeaaaaaaaaafaaaaoeabaaaaaa dp4 r0.y, a0, c5
bfaaaaaaabaaahacaaaaaakeacaaaaaaaaaaaaaaaaaaaaaa neg r1.xyz, r0.xyzz
abaaaaaaabaaahacabaaaakeacaaaaaaaiaaaaoeabaaaaaa add r1.xyz, r1.xyzz, c8
aaaaaaaaaaaaahacagaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r0.xyz, c6
adaaaaaaaaaaahacajaaaappabaaaaaaaaaaaakeacaaaaaa mul r0.xyz, c9.w, r0.xyzz
bcaaaaaaaaaaaiacabaaaakeacaaaaaaabaaaakeacaaaaaa dp3 r0.w, r1.xyzz, r1.xyzz
akaaaaaaaaaaaiacaaaaaappacaaaaaaaaaaaaaaaaaaaaaa rsq r0.w, r0.w
bcaaaaaaacaaacaeadaaaakeacaaaaaaacaaaakeacaaaaaa dp3 v2.y, r3.xyzz, r2.xyzz
bcaaaaaaadaaacaeacaaaakeacaaaaaaaeaaaakeacaaaaaa dp3 v3.y, r2.xyzz, r4.xyzz
bcaaaaaaaeaaacaeacaaaakeacaaaaaaaaaaaakeacaaaaaa dp3 v4.y, r2.xyzz, r0.xyzz
adaaaaaaafaaahaeaaaaaappacaaaaaaabaaaakeacaaaaaa mul v5.xyz, r0.w, r1.xyzz
bcaaaaaaacaaaeaeabaaaaoeaaaaaaaaadaaaakeacaaaaaa dp3 v2.z, a1, r3.xyzz
bcaaaaaaacaaabaeadaaaakeacaaaaaaafaaaaoeaaaaaaaa dp3 v2.x, r3.xyzz, a5
bcaaaaaaadaaaeaeabaaaaoeaaaaaaaaaeaaaakeacaaaaaa dp3 v3.z, a1, r4.xyzz
bcaaaaaaadaaabaeafaaaaoeaaaaaaaaaeaaaakeacaaaaaa dp3 v3.x, a5, r4.xyzz
bcaaaaaaaeaaaeaeabaaaaoeaaaaaaaaaaaaaakeacaaaaaa dp3 v4.z, a1, r0.xyzz
bcaaaaaaaeaaabaeafaaaaoeaaaaaaaaaaaaaakeacaaaaaa dp3 v4.x, a5, r0.xyzz
adaaaaaaaaaaamacaeaaaaeeaaaaaaaaakaaaaeeabaaaaaa mul r0.zw, a4.xyxy, c10.xyxy
abaaaaaaaaaaamaeaaaaaaopacaaaaaaakaaaaoeabaaaaaa add v0.zw, r0.wwzw, c10
adaaaaaaaaaaadacadaaaaoeaaaaaaaaalaaaaoeabaaaaaa mul r0.xy, a3, c11
abaaaaaaaaaaadaeaaaaaafeacaaaaaaalaaaaooabaaaaaa add v0.xy, r0.xyyy, c11.zwzw
bdaaaaaaaaaaaiadaaaaaaoeaaaaaaaaadaaaaoeabaaaaaa dp4 o0.w, a0, c3
bdaaaaaaaaaaaeadaaaaaaoeaaaaaaaaacaaaaoeabaaaaaa dp4 o0.z, a0, c2
bdaaaaaaaaaaacadaaaaaaoeaaaaaaaaabaaaaoeabaaaaaa dp4 o0.y, a0, c1
bdaaaaaaaaaaabadaaaaaaoeaaaaaaaaaaaaaaoeabaaaaaa dp4 o0.x, a0, c0
aaaaaaaaacaaaiaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v2.w, c0
aaaaaaaaadaaaiaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v3.w, c0
aaaaaaaaaeaaaiaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v4.w, c0
aaaaaaaaafaaaiaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v5.w, c0
"
}

SubProgram "d3d11_9x " {
Keywords { "LIGHTMAP_ON" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "texcoord" TexCoord0
Bind "texcoord1" TexCoord1
Bind "color" Color
ConstBuffer "$Globals" 64 // 64 used size, 4 vars
Vector 32 [unity_LightmapST] 4
Vector 48 [_MainTex_ST] 4
ConstBuffer "UnityPerCamera" 128 // 76 used size, 8 vars
Vector 64 [_WorldSpaceCameraPos] 3
ConstBuffer "UnityPerDraw" 336 // 336 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
Matrix 192 [_Object2World] 4
Vector 320 [unity_Scale] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
BindCB "UnityPerDraw" 2
// 39 instructions, 2 temp regs, 0 temp arrays:
// ALU 29 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0_level_9_1
eefiecedfnnmmojeadedkbiehepogmaddfohafmpabaaaaaaeiakaaaaaeaaaaaa
daaaaaaagiadaaaamiaiaaaajaajaaaaebgpgodjdaadaaaadaadaaaaaaacpopp
mmacaaaageaaaaaaafaaceaaaaaagaaaaaaagaaaaaaaceaaabaagaaaaaaaacaa
acaaabaaaaaaaaaaabaaaeaaabaaadaaaaaaaaaaacaaaaaaaeaaaeaaaaaaaaaa
acaaamaaaeaaaiaaaaaaaaaaacaabeaaabaaamaaaaaaaaaaaaaaaaaaaaacpopp
bpaaaaacafaaaaiaaaaaapjabpaaaaacafaaabiaabaaapjabpaaaaacafaaacia
acaaapjabpaaaaacafaaadiaadaaapjabpaaaaacafaaaeiaaeaaapjaaeaaaaae
aaaaadoaadaaoejaacaaoekaacaaookaaeaaaaaeaaaaamoaaeaaeejaabaaeeka
abaaoekaafaaaaadaaaaahiaaaaaffjaajaaoekaaeaaaaaeaaaaahiaaiaaoeka
aaaaaajaaaaaoeiaaeaaaaaeaaaaahiaakaaoekaaaaakkjaaaaaoeiaaeaaaaae
aaaaahiaalaaoekaaaaappjaaaaaoeiaacaaaaadaaaaahiaaaaaoeibadaaoeka
aiaaaaadaaaaaiiaaaaaoeiaaaaaoeiaahaaaaacaaaaaiiaaaaappiaafaaaaad
aeaaahoaaaaappiaaaaaoeiaabaaaaacaaaaabiaaiaaaakaabaaaaacaaaaacia
ajaaaakaabaaaaacaaaaaeiaakaaaakaafaaaaadaaaaahiaaaaaoeiaamaappka
aiaaaaadabaaaboaabaaoejaaaaaoeiaabaaaaacabaaahiaabaaoejaafaaaaad
acaaahiaabaamjiaacaancjaaeaaaaaeabaaahiaacaamjjaabaanciaacaaoeib
afaaaaadabaaahiaabaaoeiaabaappjaaiaaaaadabaaacoaabaaoeiaaaaaoeia
aiaaaaadabaaaeoaacaaoejaaaaaoeiaabaaaaacaaaaabiaaiaaffkaabaaaaac
aaaaaciaajaaffkaabaaaaacaaaaaeiaakaaffkaafaaaaadaaaaahiaaaaaoeia
amaappkaaiaaaaadacaaaboaabaaoejaaaaaoeiaaiaaaaadacaaacoaabaaoeia
aaaaoeiaaiaaaaadacaaaeoaacaaoejaaaaaoeiaabaaaaacaaaaabiaaiaakkka
abaaaaacaaaaaciaajaakkkaabaaaaacaaaaaeiaakaakkkaafaaaaadaaaaahia
aaaaoeiaamaappkaaiaaaaadadaaaboaabaaoejaaaaaoeiaaiaaaaadadaaacoa
abaaoeiaaaaaoeiaaiaaaaadadaaaeoaacaaoejaaaaaoeiaafaaaaadaaaaapia
aaaaffjaafaaoekaaeaaaaaeaaaaapiaaeaaoekaaaaaaajaaaaaoeiaaeaaaaae
aaaaapiaagaaoekaaaaakkjaaaaaoeiaaeaaaaaeaaaaapiaahaaoekaaaaappja
aaaaoeiaaeaaaaaeaaaaadmaaaaappiaaaaaoekaaaaaoeiaabaaaaacaaaaamma
aaaaoeiappppaaaafdeieefcfiafaaaaeaaaabaafgabaaaafjaaaaaeegiocaaa
aaaaaaaaaeaaaaaafjaaaaaeegiocaaaabaaaaaaafaaaaaafjaaaaaeegiocaaa
acaaaaaabfaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaadpcbabaaaabaaaaaa
fpaaaaadhcbabaaaacaaaaaafpaaaaaddcbabaaaadaaaaaafpaaaaaddcbabaaa
aeaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaadpccabaaaabaaaaaa
gfaaaaadhccabaaaacaaaaaagfaaaaadhccabaaaadaaaaaagfaaaaadhccabaaa
aeaaaaaagfaaaaadhccabaaaafaaaaaagiaaaaacacaaaaaadiaaaaaipcaabaaa
aaaaaaaafgbfbaaaaaaaaaaaegiocaaaacaaaaaaabaaaaaadcaaaaakpcaabaaa
aaaaaaaaegiocaaaacaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaa
dcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaaacaaaaaakgbkbaaaaaaaaaaa
egaobaaaaaaaaaaadcaaaaakpccabaaaaaaaaaaaegiocaaaacaaaaaaadaaaaaa
pgbpbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaaldccabaaaabaaaaaaegbabaaa
adaaaaaaegiacaaaaaaaaaaaadaaaaaaogikcaaaaaaaaaaaadaaaaaadcaaaaal
mccabaaaabaaaaaaagbebaaaaeaaaaaaagiecaaaaaaaaaaaacaaaaaakgiocaaa
aaaaaaaaacaaaaaadgaaaaagbcaabaaaaaaaaaaaakiacaaaacaaaaaaamaaaaaa
dgaaaaagccaabaaaaaaaaaaaakiacaaaacaaaaaaanaaaaaadgaaaaagecaabaaa
aaaaaaaaakiacaaaacaaaaaaaoaaaaaadiaaaaaihcaabaaaaaaaaaaaegacbaaa
aaaaaaaapgipcaaaacaaaaaabeaaaaaabaaaaaahbccabaaaacaaaaaaegbcbaaa
abaaaaaaegacbaaaaaaaaaaabaaaaaaheccabaaaacaaaaaaegbcbaaaacaaaaaa
egacbaaaaaaaaaaadiaaaaahhcaabaaaabaaaaaajgbebaaaabaaaaaacgbjbaaa
acaaaaaadcaaaaakhcaabaaaabaaaaaajgbebaaaacaaaaaacgbjbaaaabaaaaaa
egacbaiaebaaaaaaabaaaaaadiaaaaahhcaabaaaabaaaaaaegacbaaaabaaaaaa
pgbpbaaaabaaaaaabaaaaaahcccabaaaacaaaaaaegacbaaaabaaaaaaegacbaaa
aaaaaaaadgaaaaagbcaabaaaaaaaaaaabkiacaaaacaaaaaaamaaaaaadgaaaaag
ccaabaaaaaaaaaaabkiacaaaacaaaaaaanaaaaaadgaaaaagecaabaaaaaaaaaaa
bkiacaaaacaaaaaaaoaaaaaadiaaaaaihcaabaaaaaaaaaaaegacbaaaaaaaaaaa
pgipcaaaacaaaaaabeaaaaaabaaaaaahcccabaaaadaaaaaaegacbaaaabaaaaaa
egacbaaaaaaaaaaabaaaaaahbccabaaaadaaaaaaegbcbaaaabaaaaaaegacbaaa
aaaaaaaabaaaaaaheccabaaaadaaaaaaegbcbaaaacaaaaaaegacbaaaaaaaaaaa
dgaaaaagbcaabaaaaaaaaaaackiacaaaacaaaaaaamaaaaaadgaaaaagccaabaaa
aaaaaaaackiacaaaacaaaaaaanaaaaaadgaaaaagecaabaaaaaaaaaaackiacaaa
acaaaaaaaoaaaaaadiaaaaaihcaabaaaaaaaaaaaegacbaaaaaaaaaaapgipcaaa
acaaaaaabeaaaaaabaaaaaahcccabaaaaeaaaaaaegacbaaaabaaaaaaegacbaaa
aaaaaaaabaaaaaahbccabaaaaeaaaaaaegbcbaaaabaaaaaaegacbaaaaaaaaaaa
baaaaaaheccabaaaaeaaaaaaegbcbaaaacaaaaaaegacbaaaaaaaaaaadiaaaaai
hcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiccaaaacaaaaaaanaaaaaadcaaaaak
hcaabaaaaaaaaaaaegiccaaaacaaaaaaamaaaaaaagbabaaaaaaaaaaaegacbaaa
aaaaaaaadcaaaaakhcaabaaaaaaaaaaaegiccaaaacaaaaaaaoaaaaaakgbkbaaa
aaaaaaaaegacbaaaaaaaaaaadcaaaaakhcaabaaaaaaaaaaaegiccaaaacaaaaaa
apaaaaaapgbpbaaaaaaaaaaaegacbaaaaaaaaaaaaaaaaaajhcaabaaaaaaaaaaa
egacbaiaebaaaaaaaaaaaaaaegiccaaaabaaaaaaaeaaaaaabaaaaaahicaabaaa
aaaaaaaaegacbaaaaaaaaaaaegacbaaaaaaaaaaaeeaaaaaficaabaaaaaaaaaaa
dkaabaaaaaaaaaaadiaaaaahhccabaaaafaaaaaapgapbaaaaaaaaaaaegacbaaa
aaaaaaaadoaaaaabejfdeheomaaaaaaaagaaaaaaaiaaaaaajiaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaaaaaaaaaapapaaaakbaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
abaaaaaaapapaaaakjaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaaahahaaaa
laaaaaaaaaaaaaaaaaaaaaaaadaaaaaaadaaaaaaapadaaaalaaaaaaaabaaaaaa
aaaaaaaaadaaaaaaaeaaaaaaapadaaaaljaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
afaaaaaaapaaaaaafaepfdejfeejepeoaafeebeoehefeofeaaeoepfcenebemaa
feeffiedepepfceeaaedepemepfcaaklepfdeheolaaaaaaaagaaaaaaaiaaaaaa
jiaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaakeaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaabaaaaaaapaaaaaakeaaaaaaacaaaaaaaaaaaaaaadaaaaaa
acaaaaaaahaiaaaakeaaaaaaadaaaaaaaaaaaaaaadaaaaaaadaaaaaaahaiaaaa
keaaaaaaaeaaaaaaaaaaaaaaadaaaaaaaeaaaaaaahaiaaaakeaaaaaaafaaaaaa
aaaaaaaaadaaaaaaafaaaaaaahaiaaaafdfgfpfaepfdejfeejepeoaafeeffied
epepfceeaaklklkl"
}

SubProgram "gles3 " {
Keywords { "LIGHTMAP_ON" }
"!!GLES3#version 300 es


#ifdef VERTEX

#define gl_Vertex _glesVertex
in vec4 _glesVertex;
#define gl_Color _glesColor
in vec4 _glesColor;
#define gl_Normal (normalize(_glesNormal))
in vec3 _glesNormal;
#define gl_MultiTexCoord0 _glesMultiTexCoord0
in vec4 _glesMultiTexCoord0;
#define gl_MultiTexCoord1 _glesMultiTexCoord1
in vec4 _glesMultiTexCoord1;
#define TANGENT vec4(normalize(_glesTANGENT.xyz), _glesTANGENT.w)
in vec4 _glesTANGENT;
mat2 xll_transpose_mf2x2(mat2 m) {
  return mat2( m[0][0], m[1][0], m[0][1], m[1][1]);
}
mat3 xll_transpose_mf3x3(mat3 m) {
  return mat3( m[0][0], m[1][0], m[2][0],
               m[0][1], m[1][1], m[2][1],
               m[0][2], m[1][2], m[2][2]);
}
mat4 xll_transpose_mf4x4(mat4 m) {
  return mat4( m[0][0], m[1][0], m[2][0], m[3][0],
               m[0][1], m[1][1], m[2][1], m[3][1],
               m[0][2], m[1][2], m[2][2], m[3][2],
               m[0][3], m[1][3], m[2][3], m[3][3]);
}
vec2 xll_matrixindex_mf2x2_i (mat2 m, int i) { vec2 v; v.x=m[0][i]; v.y=m[1][i]; return v; }
vec3 xll_matrixindex_mf3x3_i (mat3 m, int i) { vec3 v; v.x=m[0][i]; v.y=m[1][i]; v.z=m[2][i]; return v; }
vec4 xll_matrixindex_mf4x4_i (mat4 m, int i) { vec4 v; v.x=m[0][i]; v.y=m[1][i]; v.z=m[2][i]; v.w=m[3][i]; return v; }
#line 167
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 203
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 197
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 83
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
#line 57
struct v2f_full {
    highp vec4 pos;
    mediump vec4 uv;
    mediump vec3 tsBase0;
    mediump vec3 tsBase1;
    mediump vec3 tsBase2;
    mediump vec3 viewDir;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform highp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 67
uniform lowp vec4 unity_ColorSpaceGrey;
#line 93
#line 98
#line 103
#line 107
#line 112
#line 136
#line 153
#line 174
#line 182
#line 209
#line 222
#line 231
#line 236
#line 245
#line 250
#line 259
#line 276
#line 281
#line 307
#line 315
#line 323
#line 327
#line 331
uniform sampler2D _MainTex;
uniform sampler2D _Normal;
uniform samplerCube _Cube;
uniform mediump float _OneMinusReflectivity;
#line 335
#line 343
uniform highp vec4 unity_LightmapST;
uniform sampler2D unity_Lightmap;
#line 351
uniform highp vec4 _MainTex_ST;
#line 103
highp vec3 WorldSpaceViewDir( in highp vec4 v ) {
    return (_WorldSpaceCameraPos.xyz - (_Object2World * v).xyz);
}
#line 335
void WriteTangentSpaceData( in appdata_full v, out mediump vec3 ts0, out mediump vec3 ts1, out mediump vec3 ts2 ) {
    highp vec3 binormal = (cross( v.normal, v.tangent.xyz) * v.tangent.w);
    highp mat3 rotation = xll_transpose_mf3x3(mat3( v.tangent.xyz, binormal, v.normal));
    #line 339
    ts0 = (rotation * (xll_matrixindex_mf4x4_i (_Object2World, 0).xyz * unity_Scale.w));
    ts1 = (rotation * (xll_matrixindex_mf4x4_i (_Object2World, 1).xyz * unity_Scale.w));
    ts2 = (rotation * (xll_matrixindex_mf4x4_i (_Object2World, 2).xyz * unity_Scale.w));
}
#line 352
v2f_full vert( in appdata_full v ) {
    v2f_full o;
    #line 355
    o.pos = (glstate_matrix_mvp * v.vertex);
    o.uv.xy = ((v.texcoord.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
    o.uv.zw = ((v.texcoord1.xy * unity_LightmapST.xy) + unity_LightmapST.zw);
    o.viewDir = normalize(WorldSpaceViewDir( v.vertex));
    #line 359
    WriteTangentSpaceData( v, o.tsBase0, o.tsBase1, o.tsBase2);
    return o;
}

out mediump vec4 xlv_TEXCOORD0;
out mediump vec3 xlv_TEXCOORD2;
out mediump vec3 xlv_TEXCOORD3;
out mediump vec3 xlv_TEXCOORD4;
out mediump vec3 xlv_TEXCOORD5;
void main() {
    v2f_full xl_retval;
    appdata_full xlt_v;
    xlt_v.vertex = vec4(gl_Vertex);
    xlt_v.tangent = vec4(TANGENT);
    xlt_v.normal = vec3(gl_Normal);
    xlt_v.texcoord = vec4(gl_MultiTexCoord0);
    xlt_v.texcoord1 = vec4(gl_MultiTexCoord1);
    xlt_v.color = vec4(gl_Color);
    xl_retval = vert( xlt_v);
    gl_Position = vec4(xl_retval.pos);
    xlv_TEXCOORD0 = vec4(xl_retval.uv);
    xlv_TEXCOORD2 = vec3(xl_retval.tsBase0);
    xlv_TEXCOORD3 = vec3(xl_retval.tsBase1);
    xlv_TEXCOORD4 = vec3(xl_retval.tsBase2);
    xlv_TEXCOORD5 = vec3(xl_retval.viewDir);
}


#endif
#ifdef FRAGMENT

#define gl_FragData _glesFragData
layout(location = 0) out mediump vec4 _glesFragData[4];
float xll_saturate_f( float x) {
  return clamp( x, 0.0, 1.0);
}
vec2 xll_saturate_vf2( vec2 x) {
  return clamp( x, 0.0, 1.0);
}
vec3 xll_saturate_vf3( vec3 x) {
  return clamp( x, 0.0, 1.0);
}
vec4 xll_saturate_vf4( vec4 x) {
  return clamp( x, 0.0, 1.0);
}
mat2 xll_saturate_mf2x2(mat2 m) {
  return mat2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));
}
mat3 xll_saturate_mf3x3(mat3 m) {
  return mat3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));
}
mat4 xll_saturate_mf4x4(mat4 m) {
  return mat4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));
}
#line 167
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 203
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 197
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 83
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
#line 57
struct v2f_full {
    highp vec4 pos;
    mediump vec4 uv;
    mediump vec3 tsBase0;
    mediump vec3 tsBase1;
    mediump vec3 tsBase2;
    mediump vec3 viewDir;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform highp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 67
uniform lowp vec4 unity_ColorSpaceGrey;
#line 93
#line 98
#line 103
#line 107
#line 112
#line 136
#line 153
#line 174
#line 182
#line 209
#line 222
#line 231
#line 236
#line 245
#line 250
#line 259
#line 276
#line 281
#line 307
#line 315
#line 323
#line 327
#line 331
uniform sampler2D _MainTex;
uniform sampler2D _Normal;
uniform samplerCube _Cube;
uniform mediump float _OneMinusReflectivity;
#line 335
#line 343
uniform highp vec4 unity_LightmapST;
uniform sampler2D unity_Lightmap;
#line 351
uniform highp vec4 _MainTex_ST;
#line 193
lowp vec3 DecodeLightmap( in lowp vec4 color ) {
    #line 195
    return (2.0 * color.xyz);
}
#line 288
lowp vec3 UnpackNormal( in lowp vec4 packednormal ) {
    #line 290
    return ((packednormal.xyz * 2.0) - 1.0);
}
#line 362
lowp vec4 frag( in v2f_full i ) {
    #line 364
    mediump vec3 nrml = UnpackNormal( texture( _Normal, i.uv.xy));
    mediump vec3 bumpedNormal = vec3( dot( i.tsBase0, nrml), dot( i.tsBase1, nrml), dot( i.tsBase2, nrml));
    bumpedNormal = ((bumpedNormal + i.viewDir.xyz) * 0.5);
    lowp vec4 tex = texture( _MainTex, i.uv.xy);
    #line 368
    mediump vec3 reflectVector = reflect( (-i.viewDir.xyz), bumpedNormal.xyz);
    lowp vec4 reflection = texture( _Cube, reflectVector);
    tex += (reflection * xll_saturate_f((tex.w - _OneMinusReflectivity)));
    lowp vec3 lm = DecodeLightmap( texture( unity_Lightmap, i.uv.zw));
    #line 372
    tex.xyz *= lm;
    return tex;
}
in mediump vec4 xlv_TEXCOORD0;
in mediump vec3 xlv_TEXCOORD2;
in mediump vec3 xlv_TEXCOORD3;
in mediump vec3 xlv_TEXCOORD4;
in mediump vec3 xlv_TEXCOORD5;
void main() {
    lowp vec4 xl_retval;
    v2f_full xlt_i;
    xlt_i.pos = vec4(0.0);
    xlt_i.uv = vec4(xlv_TEXCOORD0);
    xlt_i.tsBase0 = vec3(xlv_TEXCOORD2);
    xlt_i.tsBase1 = vec3(xlv_TEXCOORD3);
    xlt_i.tsBase2 = vec3(xlv_TEXCOORD4);
    xlt_i.viewDir = vec3(xlv_TEXCOORD5);
    xl_retval = frag( xlt_i);
    gl_FragData[0] = vec4(xl_retval);
}


#endif"
}

}
Program "fp" {
// Fragment combos: 2
//   opengl - ALU: 19 to 23, TEX: 3 to 4
//   d3d9 - ALU: 20 to 22, TEX: 3 to 4
//   d3d11 - ALU: 16 to 18, TEX: 3 to 4, FLOW: 1 to 1
//   d3d11_9x - ALU: 16 to 18, TEX: 3 to 4, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { "LIGHTMAP_OFF" }
Float 0 [_OneMinusReflectivity]
SetTexture 0 [_Normal] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_Cube] CUBE
"!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 19 ALU, 3 TEX
PARAM c[2] = { program.local[0],
		{ 0.75, 1, 2, 0.5 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEX R0.yw, fragment.texcoord[0], texture[0], 2D;
MAD R0.xy, R0.wyzw, c[1].z, -c[1].y;
MUL R0.zw, R0.xyxy, R0.xyxy;
ADD_SAT R0.z, R0, R0.w;
ADD R0.z, -R0, c[1].y;
RSQ R0.z, R0.z;
RCP R0.z, R0.z;
DP3 R1.x, fragment.texcoord[2], R0;
DP3 R1.z, R0, fragment.texcoord[4];
DP3 R1.y, R0, fragment.texcoord[3];
ADD R0.xyz, R1, fragment.texcoord[5];
MUL R1.xyz, R0, -fragment.texcoord[5];
DP3 R0.w, R1, c[1].w;
MAD R0.xyz, -R0, R0.w, -fragment.texcoord[5];
TEX R1, fragment.texcoord[0], texture[1], 2D;
TEX R0, R0, texture[2], CUBE;
ADD_SAT R2.x, R1.w, -c[0];
MAD R0, R0, R2.x, R1;
MUL result.color, R0, c[1].xxxy;
END
# 19 instructions, 3 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_OFF" }
Float 0 [_OneMinusReflectivity]
SetTexture 0 [_Normal] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_Cube] CUBE
"ps_2_0
; 20 ALU, 3 TEX
dcl_2d s0
dcl_2d s1
dcl_cube s2
def c1, 2.00000000, -1.00000000, 1.00000000, 0.50000000
def c2, 0.75000000, 1.00000000, 0, 0
dcl t0.xy
dcl t2.xyz
dcl t3.xyz
dcl t4.xyz
dcl t5.xyz
texld r0, t0, s0
mov r0.x, r0.w
mad_pp r1.xy, r0, c1.x, c1.y
mul_pp r0.xy, r1, r1
add_pp_sat r0.x, r0, r0.y
add_pp r0.x, -r0, c1.z
rsq_pp r0.x, r0.x
rcp_pp r1.z, r0.x
dp3_pp r0.x, t2, r1
dp3_pp r0.z, r1, t4
dp3_pp r0.y, r1, t3
add_pp r0.xyz, r0, t5
mul_pp r1.xyz, r0, -t5
dp3_pp r1.x, r1, c1.w
mad_pp r0.xyz, -r0, r1.x, -t5
mov r0.w, c2.y
texld r2, r0, s2
texld r1, t0, s1
add_pp_sat r0.x, r1.w, -c0
mad_pp r1, r2, r0.x, r1
mov r0.xyz, c2.x
mul_pp r0, r1, r0
mov_pp oC0, r0
"
}

SubProgram "d3d11 " {
Keywords { "LIGHTMAP_OFF" }
ConstBuffer "$Globals" 64 // 20 used size, 4 vars
Float 16 [_OneMinusReflectivity]
BindCB "$Globals" 0
SetTexture 0 [_Normal] 2D 1
SetTexture 1 [_MainTex] 2D 0
SetTexture 2 [_Cube] CUBE 2
// 20 instructions, 3 temp regs, 0 temp arrays:
// ALU 16 float, 0 int, 0 uint
// TEX 3 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0
eefiecedidjnmaemdbcpfofkkpnoknfipoieefieabaaaaaageaeaaaaadaaaaaa
cmaaaaaaoeaaaaaabiabaaaaejfdeheolaaaaaaaagaaaaaaaiaaaaaajiaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaakeaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapadaaaakeaaaaaaacaaaaaaaaaaaaaaadaaaaaaacaaaaaa
ahahaaaakeaaaaaaadaaaaaaaaaaaaaaadaaaaaaadaaaaaaahahaaaakeaaaaaa
aeaaaaaaaaaaaaaaadaaaaaaaeaaaaaaahahaaaakeaaaaaaafaaaaaaaaaaaaaa
adaaaaaaafaaaaaaahahaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfcee
aaklklklepfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklklfdeieefceeadaaaa
eaaaaaaanbaaaaaafjaaaaaeegiocaaaaaaaaaaaacaaaaaafkaaaaadaagabaaa
aaaaaaaafkaaaaadaagabaaaabaaaaaafkaaaaadaagabaaaacaaaaaafibiaaae
aahabaaaaaaaaaaaffffaaaafibiaaaeaahabaaaabaaaaaaffffaaaafidaaaae
aahabaaaacaaaaaaffffaaaagcbaaaaddcbabaaaabaaaaaagcbaaaadhcbabaaa
acaaaaaagcbaaaadhcbabaaaadaaaaaagcbaaaadhcbabaaaaeaaaaaagcbaaaad
hcbabaaaafaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaacadaaaaaaefaaaaaj
pcaabaaaaaaaaaaaegbabaaaabaaaaaaeghobaaaaaaaaaaaaagabaaaabaaaaaa
dcaaaaapdcaabaaaaaaaaaaahgapbaaaaaaaaaaaaceaaaaaaaaaaaeaaaaaaaea
aaaaaaaaaaaaaaaaaceaaaaaaaaaialpaaaaialpaaaaaaaaaaaaaaaaapaaaaah
icaabaaaaaaaaaaaegaabaaaaaaaaaaaegaabaaaaaaaaaaaddaaaaahicaabaaa
aaaaaaaadkaabaaaaaaaaaaaabeaaaaaaaaaiadpaaaaaaaiicaabaaaaaaaaaaa
dkaabaiaebaaaaaaaaaaaaaaabeaaaaaaaaaiadpelaaaaafecaabaaaaaaaaaaa
dkaabaaaaaaaaaaabaaaaaahbcaabaaaabaaaaaaegbcbaaaacaaaaaaegacbaaa
aaaaaaaabaaaaaahccaabaaaabaaaaaaegbcbaaaadaaaaaaegacbaaaaaaaaaaa
baaaaaahecaabaaaabaaaaaaegbcbaaaaeaaaaaaegacbaaaaaaaaaaaaaaaaaah
hcaabaaaaaaaaaaaegacbaaaabaaaaaaegbcbaaaafaaaaaadiaaaaakhcaabaaa
aaaaaaaaegacbaaaaaaaaaaaaceaaaaaaaaaaadpaaaaaadpaaaaaadpaaaaaaaa
baaaaaaiicaabaaaaaaaaaaaegbcbaiaebaaaaaaafaaaaaaegacbaaaaaaaaaaa
aaaaaaahicaabaaaaaaaaaaadkaabaaaaaaaaaaadkaabaaaaaaaaaaadcaaaaal
hcaabaaaaaaaaaaaegacbaaaaaaaaaaapgapbaiaebaaaaaaaaaaaaaaegbcbaia
ebaaaaaaafaaaaaaefaaaaajpcaabaaaaaaaaaaaegacbaaaaaaaaaaaeghobaaa
acaaaaaaaagabaaaacaaaaaaefaaaaajpcaabaaaabaaaaaaegbabaaaabaaaaaa
eghobaaaabaaaaaaaagabaaaaaaaaaaaaacaaaajbcaabaaaacaaaaaadkaabaaa
abaaaaaaakiacaiaebaaaaaaaaaaaaaaabaaaaaadcaaaaajpcaabaaaaaaaaaaa
egaobaaaaaaaaaaaagaabaaaacaaaaaaegaobaaaabaaaaaadiaaaaakpccabaaa
aaaaaaaaegaobaaaaaaaaaaaaceaaaaaaaaaeadpaaaaeadpaaaaeadpaaaaiadp
doaaaaab"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_OFF" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_OFF" }
"!!GLES"
}

SubProgram "flash " {
Keywords { "LIGHTMAP_OFF" }
Float 0 [_OneMinusReflectivity]
SetTexture 0 [_Normal] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_Cube] CUBE
"agal_ps
c1 2.0 -1.0 1.0 0.5
c2 0.75 1.0 0.0 0.0
[bc]
ciaaaaaaaaaaapacaaaaaaoeaeaaaaaaaaaaaaaaafaababb tex r0, v0, s0 <2d wrap linear point>
aaaaaaaaaaaaabacaaaaaappacaaaaaaaaaaaaaaaaaaaaaa mov r0.x, r0.w
adaaaaaaabaaadacaaaaaafeacaaaaaaabaaaaaaabaaaaaa mul r1.xy, r0.xyyy, c1.x
abaaaaaaabaaadacabaaaafeacaaaaaaabaaaaffabaaaaaa add r1.xy, r1.xyyy, c1.y
adaaaaaaaaaaabacabaaaaffacaaaaaaabaaaaffacaaaaaa mul r0.x, r1.y, r1.y
bfaaaaaaacaaabacabaaaaaaacaaaaaaaaaaaaaaaaaaaaaa neg r2.x, r1.x
adaaaaaaacaaabacacaaaaaaacaaaaaaabaaaaaaacaaaaaa mul r2.x, r2.x, r1.x
acaaaaaaaaaaabacacaaaaaaacaaaaaaaaaaaaaaacaaaaaa sub r0.x, r2.x, r0.x
abaaaaaaaaaaabacaaaaaaaaacaaaaaaabaaaakkabaaaaaa add r0.x, r0.x, c1.z
akaaaaaaaaaaabacaaaaaaaaacaaaaaaaaaaaaaaaaaaaaaa rsq r0.x, r0.x
afaaaaaaabaaaeacaaaaaaaaacaaaaaaaaaaaaaaaaaaaaaa rcp r1.z, r0.x
bcaaaaaaaaaaabacacaaaaoeaeaaaaaaabaaaakeacaaaaaa dp3 r0.x, v2, r1.xyzz
bcaaaaaaaaaaaeacabaaaakeacaaaaaaaeaaaaoeaeaaaaaa dp3 r0.z, r1.xyzz, v4
bcaaaaaaaaaaacacabaaaakeacaaaaaaadaaaaoeaeaaaaaa dp3 r0.y, r1.xyzz, v3
abaaaaaaaaaaahacaaaaaakeacaaaaaaafaaaaoeaeaaaaaa add r0.xyz, r0.xyzz, v5
bfaaaaaaabaaahacafaaaaoeaeaaaaaaaaaaaaaaaaaaaaaa neg r1.xyz, v5
adaaaaaaabaaahacaaaaaakeacaaaaaaabaaaakeacaaaaaa mul r1.xyz, r0.xyzz, r1.xyzz
bcaaaaaaabaaabacabaaaakeacaaaaaaabaaaappabaaaaaa dp3 r1.x, r1.xyzz, c1.w
bfaaaaaaadaaahacaaaaaakeacaaaaaaaaaaaaaaaaaaaaaa neg r3.xyz, r0.xyzz
adaaaaaaadaaahacadaaaakeacaaaaaaabaaaaaaacaaaaaa mul r3.xyz, r3.xyzz, r1.x
acaaaaaaaaaaahacadaaaakeacaaaaaaafaaaaoeaeaaaaaa sub r0.xyz, r3.xyzz, v5
aaaaaaaaaaaaaiacacaaaaffabaaaaaaaaaaaaaaaaaaaaaa mov r0.w, c2.y
ciaaaaaaacaaapacaaaaaageacaaaaaaacaaaaaaafbababb tex r2, r0.xyzy, s2 <cube wrap linear point>
ciaaaaaaabaaapacaaaaaaoeaeaaaaaaabaaaaaaafaababb tex r1, v0, s1 <2d wrap linear point>
acaaaaaaaaaaabacabaaaappacaaaaaaaaaaaaoeabaaaaaa sub r0.x, r1.w, c0
bgaaaaaaaaaaabacaaaaaaaaacaaaaaaaaaaaaaaaaaaaaaa sat r0.x, r0.x
adaaaaaaadaaapacacaaaaoeacaaaaaaaaaaaaaaacaaaaaa mul r3, r2, r0.x
abaaaaaaabaaapacadaaaaoeacaaaaaaabaaaaoeacaaaaaa add r1, r3, r1
aaaaaaaaaaaaahacacaaaaaaabaaaaaaaaaaaaaaaaaaaaaa mov r0.xyz, c2.x
adaaaaaaaaaaapacabaaaaoeacaaaaaaaaaaaaoeacaaaaaa mul r0, r1, r0
aaaaaaaaaaaaapadaaaaaaoeacaaaaaaaaaaaaaaaaaaaaaa mov o0, r0
"
}

SubProgram "d3d11_9x " {
Keywords { "LIGHTMAP_OFF" }
ConstBuffer "$Globals" 64 // 20 used size, 4 vars
Float 16 [_OneMinusReflectivity]
BindCB "$Globals" 0
SetTexture 0 [_Normal] 2D 1
SetTexture 1 [_MainTex] 2D 0
SetTexture 2 [_Cube] CUBE 2
// 20 instructions, 3 temp regs, 0 temp arrays:
// ALU 16 float, 0 int, 0 uint
// TEX 3 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0_level_9_1
eefiecedaokchcjafajkaiaaiklklfbbeobocaffabaaaaaaleagaaaaaeaaaaaa
daaaaaaahmacaaaamiafaaaaiaagaaaaebgpgodjeeacaaaaeeacaaaaaaacpppp
aiacaaaadmaaaaaaabaadaaaaaaadmaaaaaadmaaadaaceaaaaaadmaaabaaaaaa
aaababaaacacacaaaaaaabaaabaaaaaaaaaaaaaaaaacppppfbaaaaafabaaapka
aaaaaaeaaaaaialpaaaaaaaaaaaaiadpfbaaaaafacaaapkaaaaaaadpaaaaaaaa
aaaaaaaaaaaaaaaafbaaaaafadaaapkaaaaaeadpaaaaeadpaaaaeadpaaaaiadp
bpaaaaacaaaaaaiaaaaacplabpaaaaacaaaaaaiaabaachlabpaaaaacaaaaaaia
acaachlabpaaaaacaaaaaaiaadaachlabpaaaaacaaaaaaiaaeaachlabpaaaaac
aaaaaajaaaaiapkabpaaaaacaaaaaajaabaiapkabpaaaaacaaaaaajiacaiapka
ecaaaaadaaaacpiaaaaaoelaabaioekaaeaaaaaeabaacbiaaaaappiaabaaaaka
abaaffkaaeaaaaaeabaacciaaaaaffiaabaaaakaabaaffkafkaaaaaeabaadiia
abaaoeiaabaaoeiaabaakkkaacaaaaadabaaciiaabaappibabaappkaahaaaaac
abaaciiaabaappiaagaaaaacabaaceiaabaappiaaiaaaaadaaaacbiaabaaoela
abaaoeiaaiaaaaadaaaacciaacaaoelaabaaoeiaaiaaaaadaaaaceiaadaaoela
abaaoeiaacaaaaadaaaachiaaaaaoeiaaeaaoelaafaaaaadaaaachiaaaaaoeia
acaaaakaaiaaaaadaaaaciiaaeaaoelbaaaaoeiaacaaaaadaaaaciiaaaaappia
aaaappiaaeaaaaaeaaaachiaaaaaoeiaaaaappibaeaaoelbecaaaaadaaaacpia
aaaaoeiaacaioekaecaaaaadabaacpiaaaaaoelaaaaioekaacaaaaadacaadiia
abaappiaaaaaaakbaeaaaaaeaaaacpiaaaaaoeiaacaappiaabaaoeiaafaaaaad
aaaacpiaaaaaoeiaadaaoekaabaaaaacaaaicpiaaaaaoeiappppaaaafdeieefc
eeadaaaaeaaaaaaanbaaaaaafjaaaaaeegiocaaaaaaaaaaaacaaaaaafkaaaaad
aagabaaaaaaaaaaafkaaaaadaagabaaaabaaaaaafkaaaaadaagabaaaacaaaaaa
fibiaaaeaahabaaaaaaaaaaaffffaaaafibiaaaeaahabaaaabaaaaaaffffaaaa
fidaaaaeaahabaaaacaaaaaaffffaaaagcbaaaaddcbabaaaabaaaaaagcbaaaad
hcbabaaaacaaaaaagcbaaaadhcbabaaaadaaaaaagcbaaaadhcbabaaaaeaaaaaa
gcbaaaadhcbabaaaafaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaacadaaaaaa
efaaaaajpcaabaaaaaaaaaaaegbabaaaabaaaaaaeghobaaaaaaaaaaaaagabaaa
abaaaaaadcaaaaapdcaabaaaaaaaaaaahgapbaaaaaaaaaaaaceaaaaaaaaaaaea
aaaaaaeaaaaaaaaaaaaaaaaaaceaaaaaaaaaialpaaaaialpaaaaaaaaaaaaaaaa
apaaaaahicaabaaaaaaaaaaaegaabaaaaaaaaaaaegaabaaaaaaaaaaaddaaaaah
icaabaaaaaaaaaaadkaabaaaaaaaaaaaabeaaaaaaaaaiadpaaaaaaaiicaabaaa
aaaaaaaadkaabaiaebaaaaaaaaaaaaaaabeaaaaaaaaaiadpelaaaaafecaabaaa
aaaaaaaadkaabaaaaaaaaaaabaaaaaahbcaabaaaabaaaaaaegbcbaaaacaaaaaa
egacbaaaaaaaaaaabaaaaaahccaabaaaabaaaaaaegbcbaaaadaaaaaaegacbaaa
aaaaaaaabaaaaaahecaabaaaabaaaaaaegbcbaaaaeaaaaaaegacbaaaaaaaaaaa
aaaaaaahhcaabaaaaaaaaaaaegacbaaaabaaaaaaegbcbaaaafaaaaaadiaaaaak
hcaabaaaaaaaaaaaegacbaaaaaaaaaaaaceaaaaaaaaaaadpaaaaaadpaaaaaadp
aaaaaaaabaaaaaaiicaabaaaaaaaaaaaegbcbaiaebaaaaaaafaaaaaaegacbaaa
aaaaaaaaaaaaaaahicaabaaaaaaaaaaadkaabaaaaaaaaaaadkaabaaaaaaaaaaa
dcaaaaalhcaabaaaaaaaaaaaegacbaaaaaaaaaaapgapbaiaebaaaaaaaaaaaaaa
egbcbaiaebaaaaaaafaaaaaaefaaaaajpcaabaaaaaaaaaaaegacbaaaaaaaaaaa
eghobaaaacaaaaaaaagabaaaacaaaaaaefaaaaajpcaabaaaabaaaaaaegbabaaa
abaaaaaaeghobaaaabaaaaaaaagabaaaaaaaaaaaaacaaaajbcaabaaaacaaaaaa
dkaabaaaabaaaaaaakiacaiaebaaaaaaaaaaaaaaabaaaaaadcaaaaajpcaabaaa
aaaaaaaaegaobaaaaaaaaaaaagaabaaaacaaaaaaegaobaaaabaaaaaadiaaaaak
pccabaaaaaaaaaaaegaobaaaaaaaaaaaaceaaaaaaaaaeadpaaaaeadpaaaaeadp
aaaaiadpdoaaaaabejfdeheolaaaaaaaagaaaaaaaiaaaaaajiaaaaaaaaaaaaaa
abaaaaaaadaaaaaaaaaaaaaaapaaaaaakeaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
abaaaaaaapadaaaakeaaaaaaacaaaaaaaaaaaaaaadaaaaaaacaaaaaaahahaaaa
keaaaaaaadaaaaaaaaaaaaaaadaaaaaaadaaaaaaahahaaaakeaaaaaaaeaaaaaa
aaaaaaaaadaaaaaaaeaaaaaaahahaaaakeaaaaaaafaaaaaaaaaaaaaaadaaaaaa
afaaaaaaahahaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfceeaaklklkl
epfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
aaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklkl"
}

SubProgram "gles3 " {
Keywords { "LIGHTMAP_OFF" }
"!!GLES3"
}

SubProgram "opengl " {
Keywords { "LIGHTMAP_ON" }
Float 0 [_OneMinusReflectivity]
SetTexture 0 [_Normal] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_Cube] CUBE
SetTexture 3 [unity_Lightmap] 2D
"!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 23 ALU, 4 TEX
PARAM c[2] = { program.local[0],
		{ 2, 1, 0.5, 8 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEX R0.yw, fragment.texcoord[0], texture[0], 2D;
TEX R2, fragment.texcoord[0], texture[1], 2D;
MAD R0.xy, R0.wyzw, c[1].x, -c[1].y;
MUL R0.zw, R0.xyxy, R0.xyxy;
ADD_SAT R0.z, R0, R0.w;
ADD R0.z, -R0, c[1].y;
RSQ R0.z, R0.z;
RCP R0.z, R0.z;
DP3 R1.x, fragment.texcoord[2], R0;
DP3 R1.z, R0, fragment.texcoord[4];
DP3 R1.y, R0, fragment.texcoord[3];
ADD R0.xyz, R1, fragment.texcoord[5];
MUL R1.xyz, R0, -fragment.texcoord[5];
DP3 R0.w, R1, c[1].z;
MAD R0.xyz, -R0, R0.w, -fragment.texcoord[5];
ADD_SAT R3.x, R2.w, -c[0];
TEX R1, R0, texture[2], CUBE;
TEX R0, fragment.texcoord[0].zwzw, texture[3], 2D;
MAD R1, R1, R3.x, R2;
MUL R0.xyz, R0.w, R0;
MUL R0.xyz, R0, R1;
MUL result.color.xyz, R0, c[1].w;
MOV result.color.w, R1;
END
# 23 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "LIGHTMAP_ON" }
Float 0 [_OneMinusReflectivity]
SetTexture 0 [_Normal] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_Cube] CUBE
SetTexture 3 [unity_Lightmap] 2D
"ps_2_0
; 22 ALU, 4 TEX
dcl_2d s0
dcl_2d s1
dcl_cube s2
dcl_2d s3
def c1, 2.00000000, -1.00000000, 1.00000000, 0.50000000
def c2, 8.00000000, 0, 0, 0
dcl t0
dcl t2.xyz
dcl t3.xyz
dcl t4.xyz
dcl t5.xyz
texld r0, t0, s0
mov r0.x, r0.w
mad_pp r1.xy, r0, c1.x, c1.y
mul_pp r0.xy, r1, r1
add_pp_sat r0.x, r0, r0.y
add_pp r0.x, -r0, c1.z
rsq_pp r0.x, r0.x
rcp_pp r1.z, r0.x
dp3_pp r0.x, t2, r1
dp3_pp r0.z, r1, t4
dp3_pp r0.y, r1, t3
add_pp r0.xyz, r0, t5
mul_pp r1.xyz, r0, -t5
dp3_pp r1.x, r1, c1.w
mad_pp r1.xyz, -r0, r1.x, -t5
mov r0.y, t0.w
mov r0.x, t0.z
texld r2, r1, s2
texld r3, r0, s3
texld r1, t0, s1
add_pp_sat r0.x, r1.w, -c0
mad_pp r0, r2, r0.x, r1
mul_pp r1.xyz, r3.w, r3
mul_pp r0.xyz, r1, r0
mul_pp r0.xyz, r0, c2.x
mov_pp oC0, r0
"
}

SubProgram "d3d11 " {
Keywords { "LIGHTMAP_ON" }
ConstBuffer "$Globals" 64 // 20 used size, 4 vars
Float 16 [_OneMinusReflectivity]
BindCB "$Globals" 0
SetTexture 0 [_Normal] 2D 1
SetTexture 1 [_MainTex] 2D 0
SetTexture 2 [_Cube] CUBE 2
SetTexture 3 [unity_Lightmap] 2D 3
// 24 instructions, 3 temp regs, 0 temp arrays:
// ALU 18 float, 0 int, 0 uint
// TEX 4 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0
eefiecedgpbkkekbggihlffnlgjhdjpjhdpcjmblabaaaaaaoeaeaaaaadaaaaaa
cmaaaaaaoeaaaaaabiabaaaaejfdeheolaaaaaaaagaaaaaaaiaaaaaajiaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaakeaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaakeaaaaaaacaaaaaaaaaaaaaaadaaaaaaacaaaaaa
ahahaaaakeaaaaaaadaaaaaaaaaaaaaaadaaaaaaadaaaaaaahahaaaakeaaaaaa
aeaaaaaaaaaaaaaaadaaaaaaaeaaaaaaahahaaaakeaaaaaaafaaaaaaaaaaaaaa
adaaaaaaafaaaaaaahahaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfcee
aaklklklepfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklklfdeieefcmeadaaaa
eaaaaaaapbaaaaaafjaaaaaeegiocaaaaaaaaaaaacaaaaaafkaaaaadaagabaaa
aaaaaaaafkaaaaadaagabaaaabaaaaaafkaaaaadaagabaaaacaaaaaafkaaaaad
aagabaaaadaaaaaafibiaaaeaahabaaaaaaaaaaaffffaaaafibiaaaeaahabaaa
abaaaaaaffffaaaafidaaaaeaahabaaaacaaaaaaffffaaaafibiaaaeaahabaaa
adaaaaaaffffaaaagcbaaaadpcbabaaaabaaaaaagcbaaaadhcbabaaaacaaaaaa
gcbaaaadhcbabaaaadaaaaaagcbaaaadhcbabaaaaeaaaaaagcbaaaadhcbabaaa
afaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaacadaaaaaaefaaaaajpcaabaaa
aaaaaaaaegbabaaaabaaaaaaeghobaaaaaaaaaaaaagabaaaabaaaaaadcaaaaap
dcaabaaaaaaaaaaahgapbaaaaaaaaaaaaceaaaaaaaaaaaeaaaaaaaeaaaaaaaaa
aaaaaaaaaceaaaaaaaaaialpaaaaialpaaaaaaaaaaaaaaaaapaaaaahicaabaaa
aaaaaaaaegaabaaaaaaaaaaaegaabaaaaaaaaaaaddaaaaahicaabaaaaaaaaaaa
dkaabaaaaaaaaaaaabeaaaaaaaaaiadpaaaaaaaiicaabaaaaaaaaaaadkaabaia
ebaaaaaaaaaaaaaaabeaaaaaaaaaiadpelaaaaafecaabaaaaaaaaaaadkaabaaa
aaaaaaaabaaaaaahbcaabaaaabaaaaaaegbcbaaaacaaaaaaegacbaaaaaaaaaaa
baaaaaahccaabaaaabaaaaaaegbcbaaaadaaaaaaegacbaaaaaaaaaaabaaaaaah
ecaabaaaabaaaaaaegbcbaaaaeaaaaaaegacbaaaaaaaaaaaaaaaaaahhcaabaaa
aaaaaaaaegacbaaaabaaaaaaegbcbaaaafaaaaaadiaaaaakhcaabaaaaaaaaaaa
egacbaaaaaaaaaaaaceaaaaaaaaaaadpaaaaaadpaaaaaadpaaaaaaaabaaaaaai
icaabaaaaaaaaaaaegbcbaiaebaaaaaaafaaaaaaegacbaaaaaaaaaaaaaaaaaah
icaabaaaaaaaaaaadkaabaaaaaaaaaaadkaabaaaaaaaaaaadcaaaaalhcaabaaa
aaaaaaaaegacbaaaaaaaaaaapgapbaiaebaaaaaaaaaaaaaaegbcbaiaebaaaaaa
afaaaaaaefaaaaajpcaabaaaaaaaaaaaegacbaaaaaaaaaaaeghobaaaacaaaaaa
aagabaaaacaaaaaaefaaaaajpcaabaaaabaaaaaaegbabaaaabaaaaaaeghobaaa
abaaaaaaaagabaaaaaaaaaaaaacaaaajbcaabaaaacaaaaaadkaabaaaabaaaaaa
akiacaiaebaaaaaaaaaaaaaaabaaaaaadcaaaaajpcaabaaaaaaaaaaaegaobaaa
aaaaaaaaagaabaaaacaaaaaaegaobaaaabaaaaaaefaaaaajpcaabaaaabaaaaaa
ogbkbaaaabaaaaaaeghobaaaadaaaaaaaagabaaaadaaaaaadiaaaaahicaabaaa
abaaaaaadkaabaaaabaaaaaaabeaaaaaaaaaaaebdiaaaaahhcaabaaaabaaaaaa
egacbaaaabaaaaaapgapbaaaabaaaaaadiaaaaahhccabaaaaaaaaaaaegacbaaa
aaaaaaaaegacbaaaabaaaaaadgaaaaaficcabaaaaaaaaaaadkaabaaaaaaaaaaa
doaaaaab"
}

SubProgram "gles " {
Keywords { "LIGHTMAP_ON" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "LIGHTMAP_ON" }
"!!GLES"
}

SubProgram "flash " {
Keywords { "LIGHTMAP_ON" }
Float 0 [_OneMinusReflectivity]
SetTexture 0 [_Normal] 2D
SetTexture 1 [_MainTex] 2D
SetTexture 2 [_Cube] CUBE
SetTexture 3 [unity_Lightmap] 2D
"agal_ps
c1 2.0 -1.0 1.0 0.5
c2 8.0 0.0 0.0 0.0
[bc]
ciaaaaaaaaaaapacaaaaaaoeaeaaaaaaaaaaaaaaafaababb tex r0, v0, s0 <2d wrap linear point>
aaaaaaaaaaaaabacaaaaaappacaaaaaaaaaaaaaaaaaaaaaa mov r0.x, r0.w
adaaaaaaabaaadacaaaaaafeacaaaaaaabaaaaaaabaaaaaa mul r1.xy, r0.xyyy, c1.x
abaaaaaaabaaadacabaaaafeacaaaaaaabaaaaffabaaaaaa add r1.xy, r1.xyyy, c1.y
adaaaaaaaaaaabacabaaaaffacaaaaaaabaaaaffacaaaaaa mul r0.x, r1.y, r1.y
bfaaaaaaacaaabacabaaaaaaacaaaaaaaaaaaaaaaaaaaaaa neg r2.x, r1.x
adaaaaaaacaaabacacaaaaaaacaaaaaaabaaaaaaacaaaaaa mul r2.x, r2.x, r1.x
acaaaaaaaaaaabacacaaaaaaacaaaaaaaaaaaaaaacaaaaaa sub r0.x, r2.x, r0.x
abaaaaaaaaaaabacaaaaaaaaacaaaaaaabaaaakkabaaaaaa add r0.x, r0.x, c1.z
akaaaaaaaaaaabacaaaaaaaaacaaaaaaaaaaaaaaaaaaaaaa rsq r0.x, r0.x
afaaaaaaabaaaeacaaaaaaaaacaaaaaaaaaaaaaaaaaaaaaa rcp r1.z, r0.x
bcaaaaaaaaaaabacacaaaaoeaeaaaaaaabaaaakeacaaaaaa dp3 r0.x, v2, r1.xyzz
bcaaaaaaaaaaaeacabaaaakeacaaaaaaaeaaaaoeaeaaaaaa dp3 r0.z, r1.xyzz, v4
bcaaaaaaaaaaacacabaaaakeacaaaaaaadaaaaoeaeaaaaaa dp3 r0.y, r1.xyzz, v3
abaaaaaaaaaaahacaaaaaakeacaaaaaaafaaaaoeaeaaaaaa add r0.xyz, r0.xyzz, v5
bfaaaaaaabaaahacafaaaaoeaeaaaaaaaaaaaaaaaaaaaaaa neg r1.xyz, v5
adaaaaaaabaaahacaaaaaakeacaaaaaaabaaaakeacaaaaaa mul r1.xyz, r0.xyzz, r1.xyzz
bcaaaaaaabaaabacabaaaakeacaaaaaaabaaaappabaaaaaa dp3 r1.x, r1.xyzz, c1.w
bfaaaaaaadaaahacaaaaaakeacaaaaaaaaaaaaaaaaaaaaaa neg r3.xyz, r0.xyzz
adaaaaaaadaaahacadaaaakeacaaaaaaabaaaaaaacaaaaaa mul r3.xyz, r3.xyzz, r1.x
acaaaaaaabaaahacadaaaakeacaaaaaaafaaaaoeaeaaaaaa sub r1.xyz, r3.xyzz, v5
aaaaaaaaaaaaacacaaaaaappaeaaaaaaaaaaaaaaaaaaaaaa mov r0.y, v0.w
aaaaaaaaaaaaabacaaaaaakkaeaaaaaaaaaaaaaaaaaaaaaa mov r0.x, v0.z
ciaaaaaaacaaapacabaaaageacaaaaaaacaaaaaaafbababb tex r2, r1.xyzy, s2 <cube wrap linear point>
ciaaaaaaadaaapacaaaaaafeacaaaaaaadaaaaaaafaababb tex r3, r0.xyyy, s3 <2d wrap linear point>
ciaaaaaaabaaapacaaaaaaoeaeaaaaaaabaaaaaaafaababb tex r1, v0, s1 <2d wrap linear point>
acaaaaaaaaaaabacabaaaappacaaaaaaaaaaaaoeabaaaaaa sub r0.x, r1.w, c0
bgaaaaaaaaaaabacaaaaaaaaacaaaaaaaaaaaaaaaaaaaaaa sat r0.x, r0.x
adaaaaaaaaaaapacacaaaaoeacaaaaaaaaaaaaaaacaaaaaa mul r0, r2, r0.x
abaaaaaaaaaaapacaaaaaaoeacaaaaaaabaaaaoeacaaaaaa add r0, r0, r1
adaaaaaaabaaahacadaaaappacaaaaaaadaaaakeacaaaaaa mul r1.xyz, r3.w, r3.xyzz
adaaaaaaaaaaahacabaaaakeacaaaaaaaaaaaakeacaaaaaa mul r0.xyz, r1.xyzz, r0.xyzz
adaaaaaaaaaaahacaaaaaakeacaaaaaaacaaaaaaabaaaaaa mul r0.xyz, r0.xyzz, c2.x
aaaaaaaaaaaaapadaaaaaaoeacaaaaaaaaaaaaaaaaaaaaaa mov o0, r0
"
}

SubProgram "d3d11_9x " {
Keywords { "LIGHTMAP_ON" }
ConstBuffer "$Globals" 64 // 20 used size, 4 vars
Float 16 [_OneMinusReflectivity]
BindCB "$Globals" 0
SetTexture 0 [_Normal] 2D 1
SetTexture 1 [_MainTex] 2D 0
SetTexture 2 [_Cube] CUBE 2
SetTexture 3 [unity_Lightmap] 2D 3
// 24 instructions, 3 temp regs, 0 temp arrays:
// ALU 18 float, 0 int, 0 uint
// TEX 4 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0_level_9_1
eefiecedccoklcnkndcdocnpmfolnadgfdhipmciabaaaaaaheahaaaaaeaaaaaa
daaaaaaalmacaaaaiiagaaaaeaahaaaaebgpgodjieacaaaaieacaaaaaaacpppp
eeacaaaaeaaaaaaaabaadeaaaaaaeaaaaaaaeaaaaeaaceaaaaaaeaaaabaaaaaa
aaababaaacacacaaadadadaaaaaaabaaabaaaaaaaaaaaaaaaaacppppfbaaaaaf
abaaapkaaaaaaaeaaaaaialpaaaaaaaaaaaaiadpfbaaaaafacaaapkaaaaaaadp
aaaaaaebaaaaaaaaaaaaaaaabpaaaaacaaaaaaiaaaaacplabpaaaaacaaaaaaia
abaachlabpaaaaacaaaaaaiaacaachlabpaaaaacaaaaaaiaadaachlabpaaaaac
aaaaaaiaaeaachlabpaaaaacaaaaaajaaaaiapkabpaaaaacaaaaaajaabaiapka
bpaaaaacaaaaaajiacaiapkabpaaaaacaaaaaajaadaiapkaecaaaaadaaaacpia
aaaaoelaabaioekaaeaaaaaeabaacbiaaaaappiaabaaaakaabaaffkaaeaaaaae
abaacciaaaaaffiaabaaaakaabaaffkafkaaaaaeabaadiiaabaaoeiaabaaoeia
abaakkkaacaaaaadabaaciiaabaappibabaappkaahaaaaacabaaciiaabaappia
agaaaaacabaaceiaabaappiaaiaaaaadaaaacbiaabaaoelaabaaoeiaaiaaaaad
aaaacciaacaaoelaabaaoeiaaiaaaaadaaaaceiaadaaoelaabaaoeiaacaaaaad
aaaachiaaaaaoeiaaeaaoelaafaaaaadaaaachiaaaaaoeiaacaaaakaaiaaaaad
aaaaciiaaeaaoelbaaaaoeiaacaaaaadaaaaciiaaaaappiaaaaappiaaeaaaaae
aaaachiaaaaaoeiaaaaappibaeaaoelbabaaaaacabaacbiaaaaakklaabaaaaac
abaacciaaaaapplaecaaaaadaaaacpiaaaaaoeiaacaioekaecaaaaadacaacpia
aaaaoelaaaaioekaecaaaaadabaacpiaabaaoeiaadaioekaacaaaaadadaadiia
acaappiaaaaaaakbaeaaaaaeaaaacpiaaaaaoeiaadaappiaacaaoeiaafaaaaad
abaaciiaabaappiaacaaffkaafaaaaadabaachiaabaaoeiaabaappiaafaaaaad
aaaachiaaaaaoeiaabaaoeiaabaaaaacaaaicpiaaaaaoeiappppaaaafdeieefc
meadaaaaeaaaaaaapbaaaaaafjaaaaaeegiocaaaaaaaaaaaacaaaaaafkaaaaad
aagabaaaaaaaaaaafkaaaaadaagabaaaabaaaaaafkaaaaadaagabaaaacaaaaaa
fkaaaaadaagabaaaadaaaaaafibiaaaeaahabaaaaaaaaaaaffffaaaafibiaaae
aahabaaaabaaaaaaffffaaaafidaaaaeaahabaaaacaaaaaaffffaaaafibiaaae
aahabaaaadaaaaaaffffaaaagcbaaaadpcbabaaaabaaaaaagcbaaaadhcbabaaa
acaaaaaagcbaaaadhcbabaaaadaaaaaagcbaaaadhcbabaaaaeaaaaaagcbaaaad
hcbabaaaafaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaacadaaaaaaefaaaaaj
pcaabaaaaaaaaaaaegbabaaaabaaaaaaeghobaaaaaaaaaaaaagabaaaabaaaaaa
dcaaaaapdcaabaaaaaaaaaaahgapbaaaaaaaaaaaaceaaaaaaaaaaaeaaaaaaaea
aaaaaaaaaaaaaaaaaceaaaaaaaaaialpaaaaialpaaaaaaaaaaaaaaaaapaaaaah
icaabaaaaaaaaaaaegaabaaaaaaaaaaaegaabaaaaaaaaaaaddaaaaahicaabaaa
aaaaaaaadkaabaaaaaaaaaaaabeaaaaaaaaaiadpaaaaaaaiicaabaaaaaaaaaaa
dkaabaiaebaaaaaaaaaaaaaaabeaaaaaaaaaiadpelaaaaafecaabaaaaaaaaaaa
dkaabaaaaaaaaaaabaaaaaahbcaabaaaabaaaaaaegbcbaaaacaaaaaaegacbaaa
aaaaaaaabaaaaaahccaabaaaabaaaaaaegbcbaaaadaaaaaaegacbaaaaaaaaaaa
baaaaaahecaabaaaabaaaaaaegbcbaaaaeaaaaaaegacbaaaaaaaaaaaaaaaaaah
hcaabaaaaaaaaaaaegacbaaaabaaaaaaegbcbaaaafaaaaaadiaaaaakhcaabaaa
aaaaaaaaegacbaaaaaaaaaaaaceaaaaaaaaaaadpaaaaaadpaaaaaadpaaaaaaaa
baaaaaaiicaabaaaaaaaaaaaegbcbaiaebaaaaaaafaaaaaaegacbaaaaaaaaaaa
aaaaaaahicaabaaaaaaaaaaadkaabaaaaaaaaaaadkaabaaaaaaaaaaadcaaaaal
hcaabaaaaaaaaaaaegacbaaaaaaaaaaapgapbaiaebaaaaaaaaaaaaaaegbcbaia
ebaaaaaaafaaaaaaefaaaaajpcaabaaaaaaaaaaaegacbaaaaaaaaaaaeghobaaa
acaaaaaaaagabaaaacaaaaaaefaaaaajpcaabaaaabaaaaaaegbabaaaabaaaaaa
eghobaaaabaaaaaaaagabaaaaaaaaaaaaacaaaajbcaabaaaacaaaaaadkaabaaa
abaaaaaaakiacaiaebaaaaaaaaaaaaaaabaaaaaadcaaaaajpcaabaaaaaaaaaaa
egaobaaaaaaaaaaaagaabaaaacaaaaaaegaobaaaabaaaaaaefaaaaajpcaabaaa
abaaaaaaogbkbaaaabaaaaaaeghobaaaadaaaaaaaagabaaaadaaaaaadiaaaaah
icaabaaaabaaaaaadkaabaaaabaaaaaaabeaaaaaaaaaaaebdiaaaaahhcaabaaa
abaaaaaaegacbaaaabaaaaaapgapbaaaabaaaaaadiaaaaahhccabaaaaaaaaaaa
egacbaaaaaaaaaaaegacbaaaabaaaaaadgaaaaaficcabaaaaaaaaaaadkaabaaa
aaaaaaaadoaaaaabejfdeheolaaaaaaaagaaaaaaaiaaaaaajiaaaaaaaaaaaaaa
abaaaaaaadaaaaaaaaaaaaaaapaaaaaakeaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
abaaaaaaapapaaaakeaaaaaaacaaaaaaaaaaaaaaadaaaaaaacaaaaaaahahaaaa
keaaaaaaadaaaaaaaaaaaaaaadaaaaaaadaaaaaaahahaaaakeaaaaaaaeaaaaaa
aaaaaaaaadaaaaaaaeaaaaaaahahaaaakeaaaaaaafaaaaaaaaaaaaaaadaaaaaa
afaaaaaaahahaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfceeaaklklkl
epfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
aaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklkl"
}

SubProgram "gles3 " {
Keywords { "LIGHTMAP_ON" }
"!!GLES3"
}

}

#LINE 117

	}
} 

FallBack "AngryBots/Fallback"
}


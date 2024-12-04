/*
#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;

namespace NekoLegends
{
    public class CelShaderInspector : ShaderGUIBase
    {

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            ShowMainSection(materialEditor, properties);
            ShowDetailsSection(materialEditor, properties);
            ShowLightingSection(materialEditor, properties);
            ShowNormals(materialEditor, properties);
            //ShowSurfaceSection(materialEditor, properties);
            //ShowBlendingModeSection(materialEditor, properties);
            //ShowShadowsSection(materialEditor, properties);
        }

        protected virtual void ShowDetailsSection(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            MaterialProperty _Cel_Shader_Offset = FindProperty("_Cel_Shader_Offset", properties);
            MaterialProperty _Cel_Ramp_Smoothness = FindProperty("_Cel_Ramp_Smoothness", properties);
            MaterialProperty _Alpha_Clip_Threshold = FindProperty("_Alpha_Clip_Threshold", properties);

            
            bool showDetailsProperties = EditorPrefs.GetBool("CelShaderInspector_ShowDetailsProperties", false);
            showDetailsProperties = EditorGUILayout.BeginFoldoutHeaderGroup(showDetailsProperties, "Details");
            if (showDetailsProperties)
            {
                materialEditor.ShaderProperty(_Cel_Shader_Offset, _Cel_Shader_Offset.displayName);
                materialEditor.ShaderProperty(_Cel_Ramp_Smoothness, _Cel_Ramp_Smoothness.displayName);
                materialEditor.ShaderProperty(_Alpha_Clip_Threshold, _Alpha_Clip_Threshold.displayName);
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
            EditorPrefs.SetBool("CelShaderInspector_ShowDetailsProperties", showDetailsProperties);

        }

        protected virtual void ShowLightingSection(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            MaterialProperty _Rim_Lighting = FindProperty("_Rim_Lighting", properties);
            MaterialProperty _Rim_Brightness = FindProperty("_Rim_Brightness", properties);
            MaterialProperty _Ambient_Self_Lighting = FindProperty("_Ambient_Self_Lighting", properties);
            MaterialProperty _Emissions_Mask = FindProperty("_Emissions_Mask", properties);


            bool showDetailsProperties = EditorPrefs.GetBool("CelShaderInspector_ShowLightingProperties", false);
            showDetailsProperties = EditorGUILayout.BeginFoldoutHeaderGroup(showDetailsProperties, "Lighting");
            if (showDetailsProperties)
            {
                materialEditor.ShaderProperty(_Rim_Lighting, _Rim_Lighting.displayName);
                materialEditor.ShaderProperty(_Rim_Brightness, _Rim_Brightness.displayName);
                materialEditor.ShaderProperty(_Ambient_Self_Lighting, _Ambient_Self_Lighting.displayName);
                materialEditor.ShaderProperty(_Emissions_Mask, _Emissions_Mask.displayName);
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
            EditorPrefs.SetBool("CelShaderInspector_ShowLightingProperties", showDetailsProperties);

        }


        protected void ShowMainSection(MaterialEditor materialEditor, MaterialProperty[] properties)
        {

            ShowLogo();
            MaterialProperty _Main_Texture = FindProperty("_Main_Texture", properties);
            MaterialProperty _Texture_Scale = FindProperty("_Texture_Scale", properties); 
            MaterialProperty _Texture_Offset = FindProperty("_Texture_Offset", properties); 


            MaterialProperty _Color = FindProperty("_Color", properties);
            MaterialProperty _Shading_Color = FindProperty("_Shading_Color", properties);

            materialEditor.ShaderProperty(_Main_Texture, _Main_Texture.displayName);
            _Texture_Scale.vectorValue = EditorGUILayout.Vector2Field(_Texture_Scale.displayName, _Texture_Scale.vectorValue);
            _Texture_Offset.vectorValue = EditorGUILayout.Vector2Field(_Texture_Offset.displayName, _Texture_Offset.vectorValue);


            materialEditor.ShaderProperty(_Color, _Color.displayName);
            materialEditor.ShaderProperty(_Shading_Color, _Shading_Color.displayName);

            MaterialProperty _Cull = FindProperty("_Cull", properties);

            string[] cullOptions = new string[] { "Render Front And Back", "Back Only", "Front Only" };
            int selected = (int)_Cull.floatValue;

            EditorGUI.BeginChangeCheck();
            selected = EditorGUILayout.Popup("Render Mode", selected, cullOptions);
            if (EditorGUI.EndChangeCheck())
            {
                _Cull.floatValue = selected;
            }
        }

        protected void ShowNormals(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            //normals section
            MaterialProperty _UseNormalMap = FindProperty("_UseNormalMap", properties);
            MaterialProperty _NormalIntensity = FindProperty("_NormalIntensity", properties);
            MaterialProperty _NormalMap = FindProperty("_NormalMap", properties);

            bool showNormalsLayerProperties = EditorPrefs.GetBool("CelShaderInspector_NormalsLayerProperties", false);
            showNormalsLayerProperties = EditorGUILayout.BeginFoldoutHeaderGroup(showNormalsLayerProperties, "Normals");
            if (showNormalsLayerProperties)
            {
                materialEditor.ShaderProperty(_UseNormalMap, _UseNormalMap.displayName);
                materialEditor.ShaderProperty(_NormalIntensity, _NormalIntensity.displayName);
                materialEditor.ShaderProperty(_NormalMap, _NormalMap.displayName);
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
            EditorPrefs.SetBool("CelShaderInspector_NormalsLayerProperties", showNormalsLayerProperties);

        }

        protected virtual void ShowBlendingModeSection(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            MaterialProperty _Surface = FindProperty("_Surface", properties);
            MaterialProperty _SrcBlend = FindProperty("_SrcBlend", properties);
            MaterialProperty _DstBlend = FindProperty("_DstBlend", properties);

            if (_Surface.floatValue == 1.0f)
            {
                string[] blendModes = new string[] { "Alpha", "Multiply" };
                int selected = (_SrcBlend.floatValue == 5 && _DstBlend.floatValue == 8) ? 0 : 1;

                EditorGUI.BeginChangeCheck();
                selected = EditorGUILayout.Popup("Blending Mode", selected, blendModes);
                if (EditorGUI.EndChangeCheck())
                {
                    if (selected == 0) // Alpha
                    {
                        _SrcBlend.floatValue = 5; // SrcAlpha
                        _DstBlend.floatValue = 8; // OneMinusSrcAlpha
                    }
                    else // Multiply
                    {
                        _SrcBlend.floatValue = 3; // SrcColor
                        _DstBlend.floatValue = 0; // Zero
                    }
                }
            }
        }


        protected virtual void ShowShadowsSection(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            MaterialProperty _CastShadows = FindProperty("_CastShadows", properties);
            MaterialProperty _ReceiveShadows = FindProperty("_ReceiveShadows", properties);

            bool showShadowsProperties = EditorPrefs.GetBool("CelShaderInspector_ShowShadowsSectionProperties", false);
            showShadowsProperties = EditorGUILayout.BeginFoldoutHeaderGroup(showShadowsProperties, "Shadows");
            if (showShadowsProperties)
            {
                EditorGUI.BeginChangeCheck();
                bool castShadows = EditorGUILayout.Toggle("Cast Shadows", _CastShadows.floatValue == 1.0f);
                if (EditorGUI.EndChangeCheck())
                {
                    _CastShadows.floatValue = castShadows ? 1.0f : 0.0f;
                    materialEditor.PropertiesChanged();  // Force update the material
                }

                EditorGUI.BeginChangeCheck();
                bool receiveShadows = EditorGUILayout.Toggle("Receive Shadows", _ReceiveShadows.floatValue == 1.0f);
                if (EditorGUI.EndChangeCheck())
                {
                    _ReceiveShadows.floatValue = receiveShadows ? 1.0f : 0.0f;
                    materialEditor.PropertiesChanged();  // Force update the material
                }
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
            EditorPrefs.SetBool("CelShaderInspector_ShowShadowsSectionProperties", showShadowsProperties);
        }

        protected virtual void ShowSurfaceSection(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            MaterialProperty _Surface = FindProperty("_Surface", properties);

            // Create a foldout for surface properties
            bool showSurfaceProperties = EditorPrefs.GetBool("CelShaderInspector_ShowSurfaceProperties", false);
            showSurfaceProperties = EditorGUILayout.BeginFoldoutHeaderGroup(showSurfaceProperties, "Surface Type");
            if (showSurfaceProperties)
            {
                // Toggle for surface type
                EditorGUI.BeginChangeCheck();
                bool isOpaque = EditorGUILayout.Toggle("Opaque", _Surface.floatValue == 0.0f);
                if (EditorGUI.EndChangeCheck())
                {
                    _Surface.floatValue = isOpaque ? 0.0f : 1.0f;
                }
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
            EditorPrefs.SetBool("CelShaderInspector_ShowSurfaceProperties", showSurfaceProperties);
        }


    }

}

#endif
*/
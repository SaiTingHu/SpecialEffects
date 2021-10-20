using UnityEditor;
using UnityEngine;

namespace HT.Effects
{
    /// <summary>
    /// 色彩修正的自定义GUI
    /// </summary>
    internal sealed class CorrectShaderGUI : ShaderGUI
    {
        private MaterialProperty _UseUIAlphaClip;
        private MaterialProperty _DifferenceHue;
        private MaterialProperty _TargetHue;
        private MaterialProperty _CorrectHue;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            materialEditor.SetDefaultGUIWidths();

            DrawUseUIAlphaClip(materialEditor, properties);
            DrawDifferenceHue(materialEditor, properties);
            DrawTargetHue(materialEditor, properties);
            DrawCorrectHue(materialEditor, properties);

            EditorGUILayout.Space();
            EditorGUILayout.Space();
            materialEditor.RenderQueueField();
            materialEditor.EnableInstancingField();
            materialEditor.DoubleSidedGIField();
        }

        /// <summary>
        /// 绘制使用透明度裁剪
        /// </summary>
        private void DrawUseUIAlphaClip(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            if (_UseUIAlphaClip == null)
            {
                _UseUIAlphaClip = FindProperty("_UseUIAlphaClip", properties);
            }

            DrawShaderProperty(materialEditor, _UseUIAlphaClip);
        }
        /// <summary>
        /// 绘制最大色差
        /// </summary>
        private void DrawDifferenceHue(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            if (_DifferenceHue == null)
            {
                _DifferenceHue = FindProperty("_DifferenceHue", properties);
            }

            DrawShaderProperty(materialEditor, _DifferenceHue);
        }
        /// <summary>
        /// 绘制目标颜色
        /// </summary>
        private void DrawTargetHue(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            if (_TargetHue == null)
            {
                _TargetHue = FindProperty("_TargetHue", properties);
            }

            Color color = Color.HSVToRGB(_TargetHue.floatValue, 1, 1);
            EditorGUI.BeginChangeCheck();
            color = EditorGUILayout.ColorField(_TargetHue.displayName, color);
            if (EditorGUI.EndChangeCheck())
            {
                float h, s, v;
                Color.RGBToHSV(color, out h, out s, out v);
                _TargetHue.floatValue = h;
                EditorUtility.SetDirty(materialEditor.target);
            }
        }
        /// <summary>
        /// 绘制修正颜色
        /// </summary>
        private void DrawCorrectHue(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            if (_CorrectHue == null)
            {
                _CorrectHue = FindProperty("_CorrectHue", properties);
            }

            Color color = Color.HSVToRGB(_CorrectHue.floatValue, 1, 1);
            EditorGUI.BeginChangeCheck();
            color = EditorGUILayout.ColorField(_CorrectHue.displayName, color);
            if (EditorGUI.EndChangeCheck())
            {
                float h, s, v;
                Color.RGBToHSV(color, out h, out s, out v);
                _CorrectHue.floatValue = h;
                EditorUtility.SetDirty(materialEditor.target);
            }
        }

        /// <summary>
        /// 绘制材质的属性
        /// </summary>
        private void DrawShaderProperty(MaterialEditor materialEditor, MaterialProperty property)
        {
            if ((property.flags & (MaterialProperty.PropFlags.HideInInspector | MaterialProperty.PropFlags.PerRendererData)) == MaterialProperty.PropFlags.None)
            {
                float propertyHeight = materialEditor.GetPropertyHeight(property, property.displayName);
                Rect controlRect = EditorGUILayout.GetControlRect(true, propertyHeight, EditorStyles.layerMaskField, new GUILayoutOption[0]);
                materialEditor.ShaderProperty(controlRect, property, property.displayName);
            }
        }
    }
}
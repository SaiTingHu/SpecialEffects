using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

namespace HT.Effects
{
    /// <summary>
    /// 进阶版UI控件检视器
    /// </summary>
    internal sealed class AdvancedUIInspector
    {
        /// <summary>
        /// 特效Shader前缀
        /// </summary>
        private static readonly string EffectsPrefix = "HTSpecialEffects/UI/";
        /// <summary>
        /// 所有特效
        /// </summary>
        private static readonly string[] AllEffects = new string[]
        {
            "Basic", "CoolColor", "WarmColor", "Pixel", "Shiny", "Dissolve", "Blur", "Bloom"
        };
        /// <summary>
        /// 所有特效名称
        /// </summary>
        private static readonly string[] AllEffectNames = new string[]
        {
            "基本", "冷色", "暖色", "像素化", "闪亮", "溶解", "模糊", "泛光"
        };
        /// <summary>
        /// 空特效名称
        /// </summary>
        private static readonly string NoEffects = "<None>";
        /// <summary>
        /// 其他特效名称
        /// </summary>
        private static readonly string OtherEffects = "<Other>";
        /// <summary>
        /// 不支持动画的属性名称
        /// </summary>
        private static readonly HashSet<string> ExcludedProperties = new HashSet<string>()
        {
            "_MainTex",
            "_UseUIAlphaClip"
        };

        [MenuItem("CONTEXT/Component/Upgrade UI Component")]
        public static void UpgradeUIComponent(MenuCommand cmd)
        {
            if (cmd.context.GetType() == typeof(Image))
            {
                Image image = cmd.context as Image;
                GameObject obj = image.gameObject;
                ImageProperty property = ImageProperty.CopyProperty(image);
                Undo.DestroyObjectImmediate(image);

                AdvancedImage advancedImage = Undo.AddComponent<AdvancedImage>(obj);
                ImageProperty.PasteProperty(advancedImage, property);
                property = null;
                EditorUtility.SetDirty(obj);
            }
            else if (cmd.context.GetType() == typeof(RawImage))
            {
                RawImage image = cmd.context as RawImage;
                GameObject obj = image.gameObject;
                RawImageProperty property = RawImageProperty.CopyProperty(image);
                Undo.DestroyObjectImmediate(image);

                AdvancedRawImage advancedImage = Undo.AddComponent<AdvancedRawImage>(obj);
                RawImageProperty.PasteProperty(advancedImage, property);
                property = null;
                EditorUtility.SetDirty(obj);
            }
        }
        [MenuItem("CONTEXT/Component/Downgrade UI Component")]
        public static void DowngradeUIComponent(MenuCommand cmd)
        {
            if (cmd.context.GetType() == typeof(AdvancedImage))
            {
                AdvancedImage advancedImage = cmd.context as AdvancedImage;
                GameObject obj = advancedImage.gameObject;
                ImageProperty property = ImageProperty.CopyProperty(advancedImage);
                Undo.DestroyObjectImmediate(advancedImage);

                Image image = Undo.AddComponent<Image>(obj);
                ImageProperty.PasteProperty(image, property);
                property = null;
                EditorUtility.SetDirty(obj);
            }
            else if (cmd.context.GetType() == typeof(AdvancedRawImage))
            {
                AdvancedRawImage advancedImage = cmd.context as AdvancedRawImage;
                GameObject obj = advancedImage.gameObject;
                RawImageProperty property = RawImageProperty.CopyProperty(advancedImage);
                Undo.DestroyObjectImmediate(advancedImage);

                RawImage image = Undo.AddComponent<RawImage>(obj);
                RawImageProperty.PasteProperty(image, property);
                property = null;
                EditorUtility.SetDirty(obj);
            }
        }

        private Graphic _target;
        private List<UIEffectsPlayer> _effectsPlayers;
        private Material _material;
        private MaterialProperty[] _materialProperties;
        private string _currentEffect;

        /// <summary>
        /// 当前使用的特效
        /// </summary>
        private string CurrentEffect
        {
            get
            {
                return _currentEffect;
            }
            set
            {
                if (value == NoEffects)
                {
                    _currentEffect = NoEffects;
                    CurrentEffectName = NoEffects;
                }
                else
                {
                    int index = IndexOfEffects(value);
                    if (index == -1)
                    {
                        _currentEffect = OtherEffects;
                        CurrentEffectName = OtherEffects;
                    }
                    else
                    {
                        _currentEffect = AllEffects[index];
                        CurrentEffectName = string.Format("{0} [{1}]", AllEffects[index], AllEffectNames[index]);
                    }
                }
            }
        }
        /// <summary>
        /// 当前使用的特效名称
        /// </summary>
        private string CurrentEffectName { get; set; }

        public AdvancedUIInspector(Object target)
        {
            _target = target as Graphic;
            if (_target is AdvancedImage)
            {
                _effectsPlayers = (_target as AdvancedImage).EffectsPlayers;
            }
            else if (_target is AdvancedRawImage)
            {
                _effectsPlayers = (_target as AdvancedRawImage).EffectsPlayers;
            }
        }

        /// <summary>
        /// 刷新特效
        /// </summary>
        public void RefreshEffects()
        {
            if (_material != _target.material)
            {
                _material = _target.material;
                _materialProperties = MaterialEditor.GetMaterialProperties(new Object[] { _material });
                if (_material.IsUIDefaultMaterial())
                {
                    CurrentEffect = NoEffects;
                }
                else
                {
                    CurrentEffect = _material.shader.name.Replace(EffectsPrefix, "");
                }
            }
        }
        /// <summary>
        /// 绘制检视器GUI
        /// </summary>
        public void OnInspectorGUI()
        {
            if (CurrentEffect != NoEffects)
            {
                GUILayout.BeginHorizontal();
                GUI.color = Color.yellow;
                EditorGUILayout.TextField("Special Effects", CurrentEffectName, "Label");
                GUI.color = Color.white;
                GUILayout.EndHorizontal();

                GUILayout.BeginHorizontal();
                GUI.backgroundColor = Color.yellow;
                if (GUILayout.Button("Remove Special Effects"))
                {
                    RemoveSpecialEffects();
                }
                GUI.backgroundColor = Color.white;
                GUILayout.EndHorizontal();

                OnAnimationGUI();
            }
            else
            {
                GUILayout.BeginHorizontal();
                GUI.color = Color.green;
                EditorGUILayout.TextField("Special Effects", CurrentEffectName, "Label");
                GUI.color = Color.white;
                GUILayout.EndHorizontal();

                GUILayout.BeginHorizontal();
                GUI.backgroundColor = Color.green;
                if (GUILayout.Button("Use Special Effects"))
                {
                    GenericMenu gm = new GenericMenu();
                    for (int i = 0; i < AllEffects.Length; i++)
                    {
                        string effect = AllEffects[i];
                        string effectName = string.Format("{0} [{1}]", AllEffects[i], AllEffectNames[i]);
                        gm.AddItem(new GUIContent(effectName), false, () =>
                        {
                            UseSpecialEffects(effect);
                        });
                    }
                    gm.ShowAsContext();
                }
                GUI.backgroundColor = Color.white;
                GUILayout.EndHorizontal();
            }
        }
        /// <summary>
        /// 属性动画GUI
        /// </summary>
        private void OnAnimationGUI()
        {
            GUILayout.BeginVertical("HelpBox");

            GUILayout.BeginHorizontal();
            GUILayout.Label("Animation", EditorStyles.boldLabel);
            GUILayout.EndHorizontal();

            for (int i = 0; i < _effectsPlayers.Count; i++)
            {
                UIEffectsPlayer effectsPlayer = _effectsPlayers[i];
                
                GUILayout.BeginHorizontal();
                GUILayout.Space(10);
                effectsPlayer.IsFoldout = EditorGUILayout.Foldout(effectsPlayer.IsFoldout, effectsPlayer.DisplayName, true);
                if (effectsPlayer.IsFoldout)
                {
                    GUILayout.FlexibleSpace();
                    GUI.backgroundColor = Color.red;
                    if (GUILayout.Button("Delete", EditorStyles.miniButton))
                    {
                        _effectsPlayers.RemoveAt(i);
                        continue;
                    }
                    GUI.backgroundColor = Color.white;
                }
                GUILayout.EndHorizontal();
                
                if (effectsPlayer.IsFoldout)
                {
                    GUILayout.BeginHorizontal();
                    GUILayout.Space(20);
                    GUILayout.Label("Display Name", GUILayout.Width(EditorGUIUtility.labelWidth - 20));
                    EditorGUILayout.TextField(effectsPlayer.DisplayName);
                    GUILayout.EndHorizontal();

                    GUILayout.BeginHorizontal();
                    GUILayout.Space(20);
                    GUILayout.Label("Property Name", GUILayout.Width(EditorGUIUtility.labelWidth - 20));
                    EditorGUILayout.TextField(effectsPlayer.PropertyName);
                    GUILayout.EndHorizontal();

                    GUILayout.BeginHorizontal();
                    GUILayout.Space(20);
                    GUILayout.Label("Value Type", GUILayout.Width(EditorGUIUtility.labelWidth - 20));
                    GUILayout.Label(effectsPlayer.ValueType.ToString());
                    GUILayout.EndHorizontal();

                    GUILayout.BeginHorizontal();
                    GUILayout.Space(20);
                    GUILayout.Label("Start Value", GUILayout.Width(EditorGUIUtility.labelWidth - 20));
                    switch (effectsPlayer.ValueType)
                    {
                        case AnimationValueType.Float:
                            effectsPlayer.FloatStartValue = EditorGUILayout.FloatField(effectsPlayer.FloatStartValue);
                            break;
                        case AnimationValueType.Color:
                            effectsPlayer.ColorStartValue = EditorGUILayout.ColorField(effectsPlayer.ColorStartValue);
                            break;
                        case AnimationValueType.Vector4:
                            effectsPlayer.Vector4StartValue = EditorGUILayout.ColorField(effectsPlayer.Vector4StartValue);
                            break;
                    }
                    GUILayout.EndHorizontal();

                    GUILayout.BeginHorizontal();
                    GUILayout.Space(20);
                    GUILayout.Label("End Value", GUILayout.Width(EditorGUIUtility.labelWidth - 20));
                    switch (effectsPlayer.ValueType)
                    {
                        case AnimationValueType.Float:
                            effectsPlayer.FloatEndValue = EditorGUILayout.FloatField(effectsPlayer.FloatEndValue);
                            break;
                        case AnimationValueType.Color:
                            effectsPlayer.ColorEndValue = EditorGUILayout.ColorField(effectsPlayer.ColorEndValue);
                            break;
                        case AnimationValueType.Vector4:
                            effectsPlayer.Vector4EndValue = EditorGUILayout.ColorField(effectsPlayer.Vector4EndValue);
                            break;
                    }
                    GUILayout.EndHorizontal();

                    GUILayout.BeginHorizontal();
                    GUILayout.Space(20);
                    GUILayout.Label("Loop", GUILayout.Width(EditorGUIUtility.labelWidth - 20));
                    effectsPlayer.IsLoop = EditorGUILayout.Toggle(effectsPlayer.IsLoop);
                    GUILayout.EndHorizontal();

                    if (effectsPlayer.IsLoop)
                    {
                        GUILayout.BeginHorizontal();
                        GUILayout.Space(20);
                        GUILayout.Label("Loop Mode", GUILayout.Width(EditorGUIUtility.labelWidth - 20));
                        effectsPlayer.LoopMode = (AnimationLoopMode)EditorGUILayout.EnumPopup(effectsPlayer.LoopMode);
                        GUILayout.EndHorizontal();
                    }

                    GUILayout.BeginHorizontal();
                    GUILayout.Space(20);
                    GUILayout.Label("Duration", GUILayout.Width(EditorGUIUtility.labelWidth - 20));
                    effectsPlayer.Duration = EditorGUILayout.FloatField(effectsPlayer.Duration);
                    if (effectsPlayer.Duration <= 0)
                    {
                        effectsPlayer.Duration = 0.01f;
                    }
                    GUILayout.EndHorizontal();

                    GUILayout.BeginHorizontal();
                    GUILayout.Space(20);
                    GUILayout.Label("Play On Start", GUILayout.Width(EditorGUIUtility.labelWidth - 20));
                    effectsPlayer.IsPlayOnStart = EditorGUILayout.Toggle(effectsPlayer.IsPlayOnStart);
                    GUILayout.EndHorizontal();
                }
            }
            
            GUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();
            GUI.backgroundColor = Color.green;
            if (GUILayout.Button("New Animation", "ButtonLeft"))
            {
                GenericMenu gm = new GenericMenu();
                for (int i = 0; i < _materialProperties.Length; i++)
                {
                    MaterialProperty property = _materialProperties[i];
                    if (property.type == MaterialProperty.PropType.Texture)
                        continue;

                    if (ExcludedProperties.Contains(property.name))
                        continue;

                    if (_effectsPlayers.Exists((e) => { return e.PropertyName == property.name; }))
                    {
                        gm.AddDisabledItem(new GUIContent(property.displayName));
                    }
                    else
                    {
                        gm.AddItem(new GUIContent(property.displayName), false, () =>
                        {
                            BeginChange("New Animation");
                            AnimationValueType valueType = AnimationValueType.Float;
                            if (property.type == MaterialProperty.PropType.Float) valueType = AnimationValueType.Float;
                            else if (property.type == MaterialProperty.PropType.Range) valueType = AnimationValueType.Float;
                            else if (property.type == MaterialProperty.PropType.Color) valueType = AnimationValueType.Color;
                            else if (property.type == MaterialProperty.PropType.Vector) valueType = AnimationValueType.Vector4;
                            _effectsPlayers.Add(new UIEffectsPlayer(_target, property.name, property.displayName, valueType));
                            EndChange();
                        });
                    }
                }
                gm.ShowAsContext();
            }
            GUI.backgroundColor = Color.red;
            if (GUILayout.Button("Clear Animation", "ButtonRight"))
            {
                BeginChange("Clear Animation");
                _effectsPlayers.Clear();
                EndChange();
            }
            GUI.backgroundColor = Color.white;
            GUILayout.EndHorizontal();

            GUILayout.EndVertical();
        }

        /// <summary>
        /// 移除特效
        /// </summary>
        private void RemoveSpecialEffects()
        {
            BeginChange("Remove Special Effects");
            _target.material = null;
            EndChange();
        }
        /// <summary>
        /// 使用特效
        /// </summary>
        /// <param name="effect">特效名称</param>
        private void UseSpecialEffects(string effect)
        {
            Shader shader = Shader.Find(EffectsPrefix + effect);
            if (shader)
            {
                Material material = new Material(shader);
                material.name = "UISpecialEffects" + _target.GetInstanceID();
                AssetDatabase.CreateAsset(material, "Assets/" + material.name + ".mat");
                AssetDatabase.Refresh();
                EditorGUIUtility.PingObject(material);

                BeginChange("Use Special Effects");
                _target.material = material;
                EndChange();
            }
            else
            {
                Debug.LogError("使用UI特效失败：丢失了着色器 " + effect + "！");
            }
        }
        /// <summary>
        /// 特效的索引
        /// </summary>
        /// <param name="effect">特效</param>
        /// <returns>特效的索引</returns>
        private static int IndexOfEffects(string effect)
        {
            for (int i = 0; i < AllEffects.Length; i++)
            {
                if (AllEffects[i] == effect)
                {
                    return i;
                }
            }
            return -1;
        }

        /// <summary>
        /// 开始值改变
        /// </summary>
        /// <param name="content">改变的提示</param>
        private void BeginChange(string content)
        {
            Undo.RecordObject(_target, content);
        }
        /// <summary>
        /// 结束值改变
        /// </summary>
        private void EndChange()
        {
            EditorUtility.SetDirty(_target);
        }
    }
}
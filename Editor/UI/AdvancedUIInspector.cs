using System;
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
        private static readonly string EffectsPrefix = "HT.SpecialEffects/UI/";
        /// <summary>
        /// 所有特效
        /// </summary>
        private static readonly string[] AllEffects = new string[]
        {
            "Basic",
            "Bloom",
            "Blur",
            "BorderFlow",
            "CirclePierced",
            "CoolColor",
            "Correct",
            "CubePierced",
            "Dissolve",
            "Pixel",
            "Scan",
            "Shiny",
            "WarmColor",
            "Wave",
            "Wireframe"
        };
        /// <summary>
        /// 所有特效名称
        /// </summary>
        private static readonly string[] AllEffectNames = new string[]
        {
            "基本",
            "泛光",
            "模糊",
            "边框流动",
            "圆形镂空",
            "冷色",
            "颜色修正",
            "方格镂空",
            "溶解",
            "像素化",
            "扫描",
            "闪亮",
            "暖色",
            "波浪",
            "线框"
        };
        /// <summary>
        /// 所有特效使用的控制器
        /// </summary>
        private static readonly Dictionary<string, string> AllEffectController = new Dictionary<string, string>();
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
        private Editor _editor;
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

        public AdvancedUIInspector(Graphic target, Editor editor)
        {
            _target = target;
            _editor = editor;
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
                _materialProperties = MaterialEditor.GetMaterialProperties(new UnityEngine.Object[] { _material });
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
            GUI.enabled = !EditorApplication.isPlaying;

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

            GUI.enabled = true;
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
                        BeginChange("Delete Animation");
                        _effectsPlayers.RemoveAt(i);
                        EndChange();
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
                    GUILayout.Label("Curve", GUILayout.Width(EditorGUIUtility.labelWidth - 20));
                    effectsPlayer.Curve = EditorGUILayout.CurveField(effectsPlayer.Curve);
                    GUILayout.EndHorizontal();

                    GUILayout.BeginHorizontal();
                    GUILayout.Space(20);
                    GUILayout.Label("Start Value", GUILayout.Width(EditorGUIUtility.labelWidth - 20));
                    switch (effectsPlayer.ValueType)
                    {
                        case AnimationValueType.Float:
                            float floatValue = EditorGUILayout.FloatField(effectsPlayer.FloatStartValue);
                            if (!Mathf.Approximately(floatValue, effectsPlayer.FloatStartValue))
                            {
                                BeginChange("Change Value");
                                effectsPlayer.FloatStartValue = floatValue;
                                EndChange();
                            }
                            break;
                        case AnimationValueType.Color:
                            Color colorValue = EditorGUILayout.ColorField(effectsPlayer.ColorStartValue);
                            if (colorValue != effectsPlayer.ColorStartValue)
                            {
                                BeginChange("Change Value");
                                effectsPlayer.ColorStartValue = colorValue;
                                EndChange();
                            }
                            break;
                        case AnimationValueType.Vector4:
                            Vector4 vector4Value = EditorGUILayout.Vector4Field("", effectsPlayer.Vector4StartValue);
                            if (vector4Value != effectsPlayer.Vector4StartValue)
                            {
                                BeginChange("Change Value");
                                effectsPlayer.Vector4StartValue = vector4Value;
                                EndChange();
                            }
                            break;
                    }
                    GUILayout.EndHorizontal();

                    GUILayout.BeginHorizontal();
                    GUILayout.Space(20);
                    GUILayout.Label("End Value", GUILayout.Width(EditorGUIUtility.labelWidth - 20));
                    switch (effectsPlayer.ValueType)
                    {
                        case AnimationValueType.Float:
                            float floatValue = EditorGUILayout.FloatField(effectsPlayer.FloatEndValue);
                            if (!Mathf.Approximately(floatValue, effectsPlayer.FloatEndValue))
                            {
                                BeginChange("Change Value");
                                effectsPlayer.FloatEndValue = floatValue;
                                EndChange();
                            }
                            break;
                        case AnimationValueType.Color:
                            Color colorValue = EditorGUILayout.ColorField(effectsPlayer.ColorEndValue);
                            if (colorValue != effectsPlayer.ColorEndValue)
                            {
                                BeginChange("Change Value");
                                effectsPlayer.ColorEndValue = colorValue;
                                EndChange();
                            }
                            break;
                        case AnimationValueType.Vector4:
                            Vector4 vector4Value = EditorGUILayout.Vector4Field("", effectsPlayer.Vector4EndValue);
                            if (vector4Value != effectsPlayer.Vector4EndValue)
                            {
                                BeginChange("Change Value");
                                effectsPlayer.Vector4EndValue = vector4Value;
                                EndChange();
                            }
                            break;
                    }
                    GUILayout.EndHorizontal();

                    GUILayout.BeginHorizontal();
                    GUILayout.Space(20);
                    GUILayout.Label("Loop", GUILayout.Width(EditorGUIUtility.labelWidth - 20));
                    bool isLoop = EditorGUILayout.Toggle(effectsPlayer.IsLoop);
                    if (isLoop != effectsPlayer.IsLoop)
                    {
                        BeginChange("Change Loop State");
                        effectsPlayer.IsLoop = isLoop;
                        EndChange();
                    }
                    GUILayout.EndHorizontal();

                    if (effectsPlayer.IsLoop)
                    {
                        GUILayout.BeginHorizontal();
                        GUILayout.Space(20);
                        GUILayout.Label("Loop Mode", GUILayout.Width(EditorGUIUtility.labelWidth - 20));
                        AnimationLoopMode loopMode = (AnimationLoopMode)EditorGUILayout.EnumPopup(effectsPlayer.LoopMode);
                        if (loopMode != effectsPlayer.LoopMode)
                        {
                            BeginChange("Change Loop Mode");
                            effectsPlayer.LoopMode = loopMode;
                            EndChange();
                        }
                        GUILayout.EndHorizontal();
                    }

                    GUILayout.BeginHorizontal();
                    GUILayout.Space(20);
                    GUILayout.Label("Duration", GUILayout.Width(EditorGUIUtility.labelWidth - 20));
                    float duration = EditorGUILayout.FloatField(effectsPlayer.Duration);
                    if (!Mathf.Approximately(duration, effectsPlayer.Duration))
                    {
                        BeginChange("Change Duration");
                        if (duration <= 0) duration = 0.01f;
                        effectsPlayer.Duration = duration;
                        EndChange();
                    }
                    GUILayout.EndHorizontal();

                    GUILayout.BeginHorizontal();
                    GUILayout.Space(20);
                    GUILayout.Label("Play On Start", GUILayout.Width(EditorGUIUtility.labelWidth - 20));
                    bool isPlayOnStart = EditorGUILayout.Toggle(effectsPlayer.IsPlayOnStart);
                    if (isPlayOnStart != effectsPlayer.IsPlayOnStart)
                    {
                        BeginChange("Change PlayOnStart State");
                        effectsPlayer.IsPlayOnStart = isPlayOnStart;
                        EndChange();
                    }
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
                        gm.AddDisabledItem(new GUIContent(property.displayName), true);
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
                AddController(effect);
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
            Undo.RecordObject(_editor.target, content);
        }
        /// <summary>
        /// 添加控制器
        /// </summary>
        /// <param name="effect">特效名称</param>
        private void AddController(string effect)
        {
            if (!AllEffectController.ContainsKey(effect))
                return;

            Type type = Type.GetType(AllEffectController[effect] + ",HT.SpecialEffects");
            if (type != null && _target.gameObject.GetComponent(type) == null)
            {
                _target.gameObject.AddComponent(type);
            }
        }
        /// <summary>
        /// 结束值改变
        /// </summary>
        private void EndChange()
        {
            EditorUtility.SetDirty(_editor.target);
        }
    }
}
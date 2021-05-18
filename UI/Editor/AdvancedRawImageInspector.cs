using UnityEditor;
using UnityEditor.UI;
using UnityEngine;
using UnityEngine.UI;

namespace HT.SpecialEffects
{
    [CanEditMultipleObjects]
    [CustomEditor(typeof(AdvancedRawImage), true)]
    internal sealed class AdvancedRawImageInspector : RawImageEditor
    {
        private AdvancedRawImage _target;
        private Material _material;
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
                if (value == UISpecialEffectsEditor.NoEffects)
                {
                    _currentEffect = UISpecialEffectsEditor.NoEffects;
                    CurrentEffectName = UISpecialEffectsEditor.NoEffects;
                }
                else
                {
                    int index = UISpecialEffectsEditor.IndexOfEffects(value);
                    if (index == -1)
                    {
                        _currentEffect = UISpecialEffectsEditor.OtherEffects;
                        CurrentEffectName = UISpecialEffectsEditor.OtherEffects;
                    }
                    else
                    {
                        _currentEffect = UISpecialEffectsEditor.AllEffects[index];
                        CurrentEffectName = string.Format("{0} [{1}]", UISpecialEffectsEditor.AllEffects[index], UISpecialEffectsEditor.AllEffectNames[index]);
                    }
                }
            }
        }
        /// <summary>
        /// 当前使用的特效名称
        /// </summary>
        private string CurrentEffectName { get; set; }

        protected override void OnEnable()
        {
            base.OnEnable();

            _target = target as AdvancedRawImage;
        }
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            RefreshEffects();

            if (CurrentEffect != UISpecialEffectsEditor.NoEffects)
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
                    for (int i = 0; i < UISpecialEffectsEditor.AllEffects.Length; i++)
                    {
                        string effect = UISpecialEffectsEditor.AllEffects[i];
                        string effectName = string.Format("{0} [{1}]", UISpecialEffectsEditor.AllEffects[i], UISpecialEffectsEditor.AllEffectNames[i]);
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

        private void RefreshEffects()
        {
            if (_material != _target.material)
            {
                _material = _target.material;
                if (UISpecialEffectsEditor.IsDefaultMaterial(_material))
                {
                    CurrentEffect = UISpecialEffectsEditor.NoEffects;
                }
                else
                {
                    CurrentEffect = _material.shader.name.Replace(UISpecialEffectsEditor.EffectsPrefix, "");
                }
            }
        }
        private void RemoveSpecialEffects()
        {
            _target.material = null;
        }
        private void UseSpecialEffects(string effect)
        {
            Shader shader = Shader.Find(UISpecialEffectsEditor.EffectsPrefix + effect);
            if (shader)
            {
                Material material = new Material(shader);
                material.name = "UISpecialEffects" + _target.GetInstanceID();
                AssetDatabase.CreateAsset(material, "Assets/" + material.name + ".mat");
                AssetDatabase.Refresh();
                EditorGUIUtility.PingObject(material);
                _target.material = material;
            }
            else
            {
                Debug.LogError("使用UI特效失败：丢失了着色器 " + effect + "！");
            }
        }
    }
}
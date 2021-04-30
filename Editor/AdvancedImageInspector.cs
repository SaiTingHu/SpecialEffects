using UnityEditor;
using UnityEditor.UI;
using UnityEngine;
using UnityEngine.UI;

namespace HT.SpecialEffects
{
    [CanEditMultipleObjects]
    [CustomEditor(typeof(AdvancedImage), true)]
    internal sealed class AdvancedImageInspector : ImageEditor
    {
        [MenuItem("CONTEXT/Component/Replace With Advanced Image")]
        public static void ReplaceWithAdvancedImage(MenuCommand cmd)
        {
            if (cmd.context is Image)
            {
                Image image = cmd.context as Image;
                GameObject obj = image.gameObject;

                Undo.DestroyObjectImmediate(image);
                Undo.AddComponent<AdvancedImage>(obj);
                EditorUtility.SetDirty(obj);
            }
        }

        private static readonly string[] AllEffects = new string[] {
            "HTSpecialEffects/UI/Basic"
        };
        private static readonly string NoEffects = "<None>";
        private static readonly string OtherEffects = "<Other>";

        private AdvancedImage _target;
        private Material _material;
        private string _currentEffects;
        private int _currentEffectsIndex;
        
        protected override void OnEnable()
        {
            base.OnEnable();

            _target = target as AdvancedImage;
        }
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            RefreshEffects();

            GUILayout.BeginHorizontal();
            EditorGUILayout.TextField("Special Effects", _currentEffects, "Label");
            GUILayout.EndHorizontal();

            if (_currentEffects != NoEffects)
            {
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
                GUI.backgroundColor = Color.green;
                if (GUILayout.Button("Use Special Effects"))
                {
                    GenericMenu gm = new GenericMenu();
                    for (int i = 0; i < AllEffects.Length; i++)
                    {
                        string effect = AllEffects[i];
                        gm.AddItem(new GUIContent(effect), false, () =>
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
                if (_material == Graphic.defaultGraphicMaterial || _material == Image.defaultETC1GraphicMaterial)
                {
                    _currentEffects = NoEffects;
                    _currentEffectsIndex = -1;
                }
                else
                {
                    _currentEffects = _material.shader.name;
                    _currentEffectsIndex = IndexOfEffects(_currentEffects);
                    if (_currentEffectsIndex == -1)
                    {
                        _currentEffects = OtherEffects;
                    }
                }
            }
        }
        private int IndexOfEffects(string str)
        {
            for (int i = 0; i < AllEffects.Length; i++)
            {
                if (AllEffects[i] == str)
                {
                    return i;
                }
            }
            return -1;
        }
        private void RemoveSpecialEffects()
        {
            _target.material = null;
        }
        private void UseSpecialEffects(string effect)
        {
            Shader shader = Shader.Find(effect);
            if (shader)
            {
                Material material = new Material(Shader.Find(effect));
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
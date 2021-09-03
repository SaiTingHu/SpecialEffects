using UnityEditor;
using UnityEditor.UI;
using UnityEngine;
using UnityEngine.UI;

namespace HT.Effects
{
    [CanEditMultipleObjects]
    [CustomEditor(typeof(AdvancedRawImage), true)]
    internal sealed class AdvancedRawImageInspector : RawImageEditor
    {
        private AdvancedUIInspector _inspector;

        protected override void OnEnable()
        {
            base.OnEnable();

            if (targets.Length > 1)
                return;

            _inspector = new AdvancedUIInspector(target as Graphic, this);
        }
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            if (targets.Length > 1)
            {
                EditorGUILayout.HelpBox("Special effects not support multi-object editing.", MessageType.None);
                return;
            }

            _inspector.RefreshEffects();
            _inspector.OnInspectorGUI();

            if (GUI.changed)
            {
                EditorUtility.SetDirty(target);
            }
        }
    }
}
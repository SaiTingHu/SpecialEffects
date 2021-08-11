using UnityEditor;
using UnityEditor.UI;

namespace HT.Effects
{
    [CanEditMultipleObjects]
    [CustomEditor(typeof(AdvancedImage), true)]
    internal sealed class AdvancedImageInspector : ImageEditor
    {
        private AdvancedUIInspector _inspector;
        
        protected override void OnEnable()
        {
            base.OnEnable();

            if (targets.Length > 1)
                return;

            _inspector = new AdvancedUIInspector(target);
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
        }
    }
}
using UnityEditor;
using UnityEditor.UI;

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

            _inspector = new AdvancedUIInspector(target);
        }
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            _inspector.RefreshEffects();
            _inspector.OnInspectorGUI();
        }
    }
}
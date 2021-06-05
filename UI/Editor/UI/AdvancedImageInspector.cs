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
using UnityEngine;
using UnityEngine.UI;

namespace HT.SpecialEffects
{
    /// <summary>
    /// RawImage组件的属性
    /// </summary>
    internal sealed class RawImageProperty
    {
        /// <summary>
        /// 复制RawImage组件的属性
        /// </summary>
        /// <param name="image">RawImage组件</param>
        /// <returns>RawImage属性</returns>
        public static RawImageProperty CopyProperty(RawImage image)
        {
            RawImageProperty property = new RawImageProperty();
            property._texture = image.texture;
            property._color = image.color;
            property._material = image.material;
            property._raycastTarget = image.raycastTarget;
            property._uvRect = image.uvRect;
            if (UISpecialEffectsEditor.IsDefaultMaterial(property._material))
            {
                property._material = null;
            }
            return property;
        }
        /// <summary>
        /// 复制AdvancedRawImage组件的属性
        /// </summary>
        /// <param name="image">AdvancedRawImage组件</param>
        /// <returns>RawImage属性</returns>
        public static RawImageProperty CopyProperty(AdvancedRawImage image)
        {
            RawImageProperty property = new RawImageProperty();
            property._texture = image.texture;
            property._color = image.color;
            property._material = image.material;
            property._raycastTarget = image.raycastTarget;
            property._uvRect = image.uvRect;
            if (UISpecialEffectsEditor.IsDefaultMaterial(property._material))
            {
                property._material = null;
            }
            return property;
        }
        /// <summary>
        /// 粘贴属性到RawImage组件
        /// </summary>
        /// <param name="image">RawImage组件</param>
        /// <param name="property">RawImage属性</param>
        public static void PasteProperty(RawImage image, RawImageProperty property)
        {
            image.texture = property._texture;
            image.color = property._color;
            image.material = property._material;
            image.raycastTarget = property._raycastTarget;
            image.uvRect = property._uvRect;
        }
        /// <summary>
        /// 粘贴属性到AdvancedRawImage组件
        /// </summary>
        /// <param name="image">AdvancedRawImage组件</param>
        /// <param name="property">RawImage属性</param>
        public static void PasteProperty(AdvancedRawImage image, RawImageProperty property)
        {
            image.texture = property._texture;
            image.color = property._color;
            image.material = property._material;
            image.raycastTarget = property._raycastTarget;
            image.uvRect = property._uvRect;
        }

        private Texture _texture;
        private Color _color;
        private Material _material;
        private bool _raycastTarget;
        private Rect _uvRect;

        private RawImageProperty()
        { }
    }
}
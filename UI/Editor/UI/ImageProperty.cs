using UnityEngine;
using UnityEngine.UI;

namespace HT.Effects
{
    /// <summary>
    /// Image组件的属性
    /// </summary>
    internal sealed class ImageProperty
    {
        /// <summary>
        /// 复制Image组件的属性
        /// </summary>
        /// <param name="image">Image组件</param>
        /// <returns>Image属性</returns>
        public static ImageProperty CopyProperty(Image image)
        {
            ImageProperty property = new ImageProperty();
            property._sprite = image.sprite;
            property._color = image.color;
            property._material = image.material;
            property._raycastTarget = image.raycastTarget;
            property._type = image.type;
            property._useSpriteMesh = image.useSpriteMesh;
            property._preserveAspect = image.preserveAspect;
            property._fillCenter = image.fillCenter;
            property._fillMethod = image.fillMethod;
            property._fillOrigin = image.fillOrigin;
            property._fillAmount = image.fillAmount;
            property._fillClockwise = image.fillClockwise;
            if (property._material.IsUIDefaultMaterial())
            {
                property._material = null;
            }
            return property;
        }
        /// <summary>
        /// 复制AdvancedImage组件的属性
        /// </summary>
        /// <param name="image">AdvancedImage组件</param>
        /// <returns>Image属性</returns>
        public static ImageProperty CopyProperty(AdvancedImage image)
        {
            ImageProperty property = new ImageProperty();
            property._sprite = image.sprite;
            property._color = image.color;
            property._material = image.material;
            property._raycastTarget = image.raycastTarget;
            property._type = image.type;
            property._useSpriteMesh = image.useSpriteMesh;
            property._preserveAspect = image.preserveAspect;
            property._fillCenter = image.fillCenter;
            property._fillMethod = image.fillMethod;
            property._fillOrigin = image.fillOrigin;
            property._fillAmount = image.fillAmount;
            property._fillClockwise = image.fillClockwise;
            if (property._material.IsUIDefaultMaterial())
            {
                property._material = null;
            }
            return property;
        }
        /// <summary>
        /// 粘贴属性到Image组件
        /// </summary>
        /// <param name="image">Image组件</param>
        /// <param name="property">Image属性</param>
        public static void PasteProperty(Image image, ImageProperty property)
        {
            image.sprite = property._sprite;
            image.color = property._color;
            image.material = property._material;
            image.raycastTarget = property._raycastTarget;
            image.type = property._type;
            image.useSpriteMesh = property._useSpriteMesh;
            image.preserveAspect = property._preserveAspect;
            image.fillCenter = property._fillCenter;
            image.fillMethod = property._fillMethod;
            image.fillOrigin = property._fillOrigin;
            image.fillAmount = property._fillAmount;
            image.fillClockwise = property._fillClockwise;
        }
        /// <summary>
        /// 粘贴属性到AdvancedImage组件
        /// </summary>
        /// <param name="image">AdvancedImage组件</param>
        /// <param name="property">Image属性</param>
        public static void PasteProperty(AdvancedImage image, ImageProperty property)
        {
            image.sprite = property._sprite;
            image.color = property._color;
            image.material = property._material;
            image.raycastTarget = property._raycastTarget;
            image.type = property._type;
            image.useSpriteMesh = property._useSpriteMesh;
            image.preserveAspect = property._preserveAspect;
            image.fillCenter = property._fillCenter;
            image.fillMethod = property._fillMethod;
            image.fillOrigin = property._fillOrigin;
            image.fillAmount = property._fillAmount;
            image.fillClockwise = property._fillClockwise;
        }

        private Sprite _sprite;
        private Color _color;
        private Material _material;
        private bool _raycastTarget;
        private Image.Type _type;
        private bool _useSpriteMesh;
        private bool _preserveAspect;
        private bool _fillCenter;
        private Image.FillMethod _fillMethod;
        private int _fillOrigin;
        private float _fillAmount;
        private bool _fillClockwise;

        private ImageProperty()
        { }
    }
}
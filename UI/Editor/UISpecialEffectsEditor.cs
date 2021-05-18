using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

namespace HT.SpecialEffects
{
    /// <summary>
    /// UI特效编辑器
    /// </summary>
    internal static class UISpecialEffectsEditor
    {
        /// <summary>
        /// 特效Shader前缀
        /// </summary>
        public static readonly string EffectsPrefix = "HTSpecialEffects/UI/";
        /// <summary>
        /// 所有特效
        /// </summary>
        public static readonly string[] AllEffects = new string[] {
            "Basic", "CoolColor", "WarmColor", "Pixel", "Shiny", "Dissolve", "Blur", "Bloom"
        };
        /// <summary>
        /// 所有特效名称
        /// </summary>
        public static readonly string[] AllEffectNames = new string[] {
            "基本", "冷色", "暖色", "像素化", "闪亮", "溶解", "模糊", "泛光"
        };
        /// <summary>
        /// 空特效名称
        /// </summary>
        public static readonly string NoEffects = "<None>";
        /// <summary>
        /// 其他特效名称
        /// </summary>
        public static readonly string OtherEffects = "<Other>";

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

        /// <summary>
        /// 是否是UI默认材质
        /// </summary>
        /// <param name="material">材质</param>
        /// <returns>是否是</returns>
        public static bool IsDefaultMaterial(Material material)
        {
            return material == Graphic.defaultGraphicMaterial || material == Image.defaultETC1GraphicMaterial;
        }
        /// <summary>
        /// 特效的索引
        /// </summary>
        /// <param name="effect">特效</param>
        /// <returns>特效的索引</returns>
        public static int IndexOfEffects(string effect)
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
    }
}
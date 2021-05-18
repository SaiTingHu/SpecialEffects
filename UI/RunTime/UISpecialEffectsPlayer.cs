using System;

namespace HT.SpecialEffects
{
    /// <summary>
    /// UI特效播放器
    /// </summary>
    [Serializable]
    public class UISpecialEffectsPlayer
    {
        /// <summary>
        /// 属性名称
        /// </summary>
        public string PropertyName;
        /// <summary>
        /// 动画开始值
        /// </summary>
        public float StartValue;
        /// <summary>
        /// 动画结束值
        /// </summary>
        public float EndValue;
        /// <summary>
        /// 动画持续时间
        /// </summary>
        public float Duration;
        /// <summary>
        /// 动画是否循环
        /// </summary>
        public bool IsLoop;
    }

    /// <summary>
    /// 动画循环模式
    /// </summary>
    public enum AnimationLoopMode
    {
        /// <summary>
        /// 重新开始
        /// </summary>
        Restart,
        /// <summary>
        /// 乒乓回弹
        /// </summary>
        PingPong
    }
}
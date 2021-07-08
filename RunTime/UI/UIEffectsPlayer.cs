using System;
using UnityEngine;
using UnityEngine.UI;

namespace HT.Effects
{
    /// <summary>
    /// UI特效播放器
    /// </summary>
    [Serializable]
    public sealed class UIEffectsPlayer
    {
        /// <summary>
        /// 目标控件
        /// </summary>
        [SerializeField] internal Graphic Target;
        /// <summary>
        /// 显示名称
        /// </summary>
        [SerializeField] internal string DisplayName;
        /// <summary>
        /// 属性名称
        /// </summary>
        [SerializeField] internal string PropertyName;
        /// <summary>
        /// 动画值类型
        /// </summary>
        [SerializeField] internal AnimationValueType ValueType;
        /// <summary>
        /// 动画开始值
        /// </summary>
        [SerializeField] internal float FloatStartValue;
        /// <summary>
        /// 动画结束值
        /// </summary>
        [SerializeField] internal float FloatEndValue;
        /// <summary>
        /// 动画开始值
        /// </summary>
        [SerializeField] internal Vector4 Vector4StartValue;
        /// <summary>
        /// 动画结束值
        /// </summary>
        [SerializeField] internal Vector4 Vector4EndValue;
        /// <summary>
        /// 动画开始值
        /// </summary>
        [SerializeField] internal Color ColorStartValue;
        /// <summary>
        /// 动画结束值
        /// </summary>
        [SerializeField] internal Color ColorEndValue;
        /// <summary>
        /// 动画是否循环
        /// </summary>
        [SerializeField] internal bool IsLoop;
        /// <summary>
        /// 动画循环模式
        /// </summary>
        [SerializeField] internal AnimationLoopMode LoopMode;
        /// <summary>
        /// 动画持续时间
        /// </summary>
        [SerializeField] internal float Duration;
        /// <summary>
        /// 初始时自动播放
        /// </summary>
        [SerializeField] internal bool IsPlayOnStart;
        
#if UNITY_EDITOR
        /// <summary>
        /// 是否在检视面板折叠
        /// </summary>
        public bool IsFoldout = true;
#endif

        private bool _isPlaying = false;
        private float _playPosition = 0;
        private Action<float> _setPosition;
        private float _timeScale;

        /// <summary>
        /// 动画是否播放中
        /// </summary>
        public bool IsPlaying
        {
            get
            {
                return _isPlaying;
            }
            set
            {
                if (_isPlaying == value)
                    return;

                _isPlaying = value;
                if (_isPlaying)
                {
                    PlayPosition = 0;
                    PlayDirection = 1;
                    _timeScale = 1 / Duration;
                }
            }
        }
        /// <summary>
        /// 动画播放的位置（开始值位置：0，结束值位置：1）
        /// </summary>
        public float PlayPosition
        {
            get
            {
                return _playPosition;
            }
            set
            {
                if (_setPosition == null)
                {
                    switch (ValueType)
                    {
                        case AnimationValueType.Float:
                            _setPosition = (pos) =>
                            {
                                FloatCurrentValue = Mathf.Lerp(FloatStartValue, FloatEndValue, pos);
                                Target.material.SetFloat(PropertyName, FloatCurrentValue);
                            };
                            break;
                        case AnimationValueType.Vector4:
                            _setPosition = (pos) =>
                            {
                                Vector4CurrentValue = Vector4.Lerp(Vector4StartValue, Vector4EndValue, pos);
                                Target.material.SetVector(PropertyName, Vector4CurrentValue);
                            };
                            break;
                        case AnimationValueType.Color:
                            _setPosition = (pos) =>
                            {
                                ColorCurrentValue = Color.Lerp(ColorStartValue, ColorEndValue, pos);
                                Target.material.SetColor(PropertyName, ColorCurrentValue);
                            };
                            break;
                    }
                }

                _playPosition = value;
                _setPosition(_playPosition);
            }
        }
        /// <summary>
        /// 动画播放的方向（正方向：1，反方向：-1）
        /// </summary>
        public int PlayDirection { get; private set; }
        /// <summary>
        /// 动画当前的float值
        /// </summary>
        public float FloatCurrentValue { get; private set; }
        /// <summary>
        /// 动画当前的Vector4值
        /// </summary>
        public Vector4 Vector4CurrentValue { get; private set; }
        /// <summary>
        /// 动画当前的颜色值
        /// </summary>
        public Color ColorCurrentValue { get; private set; }

        /// <summary>
        /// UI特效播放器
        /// </summary>
        /// <param name="target">目标控件</param>
        /// <param name="propertyName">属性名称</param>
        /// <param name="displayName">显示名称</param>
        /// <param name="valueType">动画值类型</param>
        public UIEffectsPlayer(Graphic target, string propertyName, string displayName, AnimationValueType valueType)
        {
            Target = target;
            PropertyName = propertyName;
            DisplayName = displayName;
            ValueType = valueType;
            FloatStartValue = 0;
            FloatEndValue = 1;
            Vector4StartValue = Vector4.zero;
            Vector4EndValue = Vector4.one;
            ColorStartValue = Color.white;
            ColorEndValue = Color.white;
            IsLoop = false;
            LoopMode = AnimationLoopMode.Restart;
            Duration = 1;
            IsPlayOnStart = true;
        }

        /// <summary>
        /// 初始化
        /// </summary>
        internal void OnStart()
        {
            if (IsPlayOnStart)
            {
                IsPlaying = true;
            }
        }
        /// <summary>
        /// 更新动画
        /// </summary>
        /// <param name="deltaTime">增量时间</param>
        internal void OnUpdate(float deltaTime)
        {
            if (IsPlaying)
            {
                if (PlayDirection == 1)
                {
                    if (PlayPosition < 1)
                    {
                        PlayPosition += deltaTime * _timeScale;
                    }
                    else
                    {
                        PlayPosition = 1;
                        if (IsLoop)
                        {
                            if (LoopMode == AnimationLoopMode.Restart)
                            {
                                PlayPosition = 0;
                            }
                            else
                            {
                                PlayDirection = -1;
                            }
                        }
                        else
                        {
                            IsPlaying = false;
                        }
                    }
                }
                else
                {
                    if (PlayPosition > 0)
                    {
                        PlayPosition -= deltaTime * _timeScale;
                    }
                    else
                    {
                        PlayPosition = 0;
                        PlayDirection = 1;
                    }
                }
            }
        }
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

    /// <summary>
    /// 动画值类型
    /// </summary>
    public enum AnimationValueType
    {
        Float,
        Vector4,
        Color
    }
}
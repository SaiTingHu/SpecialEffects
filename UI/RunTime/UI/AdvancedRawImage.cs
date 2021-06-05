using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace HT.Effects
{
    /// <summary>
    /// 进阶版RawImage
    /// </summary>
    public sealed class AdvancedRawImage : RawImage
    {
        [SerializeField] internal List<UIEffectsPlayer> EffectsPlayers = new List<UIEffectsPlayer>();

        protected override void Start()
        {
            base.Start();

#if UNITY_EDITOR
            if (!EditorApplication.isPlaying)
                return;
#endif

            for (int i = 0; i < EffectsPlayers.Count; i++)
            {
                EffectsPlayers[i].OnStart();
            }
        }
        private void Update()
        {
#if UNITY_EDITOR
            if (!EditorApplication.isPlaying)
                return;
#endif

            if (EffectsPlayers.Count == 0)
                return;

            for (int i = 0; i < EffectsPlayers.Count; i++)
            {
                EffectsPlayers[i].OnUpdate(Time.deltaTime);
            }
        }
        
        /// <summary>
        /// 获取特效播放器
        /// </summary>
        /// <param name="propertyName">属性名称</param>
        /// <returns>特效播放器</returns>
        public UIEffectsPlayer GetEffectsPlayer(string propertyName)
        {
            return EffectsPlayers.Find((e) => { return e.PropertyName == propertyName; });
        }
        /// <summary>
        /// 设置特效播放器的播放状态
        /// </summary>
        /// <param name="propertyName">属性名称</param>
        /// <param name="playing">播放状态</param>
        public void SetEffectsPlaying(string propertyName, bool playing)
        {
            UIEffectsPlayer player = EffectsPlayers.Find((e) => { return e.PropertyName == propertyName; });
            if (player != null)
            {
                player.IsPlaying = playing;
            }
        }
        /// <summary>
        /// 设置特效播放器的播放位置（0-1之间）
        /// </summary>
        /// <param name="propertyName">属性名称</param>
        /// <param name="position">播放位置</param>
        public void SetEffectsPlayPosition(string propertyName, float position)
        {
            UIEffectsPlayer player = EffectsPlayers.Find((e) => { return e.PropertyName == propertyName; });
            if (player != null)
            {
                player.PlayPosition = position;
            }
        }
    }
}
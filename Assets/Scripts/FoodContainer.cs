using UnityEngine;

namespace MyGameNamespace
{
    [CreateAssetMenu(fileName = "FoodContainer", menuName = "MyGameNamespace/Food Container")]
    public class FoodContainer : ScriptableObject
    {
        public Food food; // 存储Food ScriptableObject 的引用
    }
}

using UnityEngine;
using MyGameNamespace;

namespace MyGameNamespace
{ 
    public enum FoodType { Meat, Vegetable, Fruit }
}
public abstract class Food : ScriptableObject
{
    public string foodName; // 食物名稱
    public FoodType type; // 食物類型

    public abstract void ConsumeEffect(Monster monster);

    // 檢查食物是否為怪物喜愛的
    public bool IsFavorite(Monster monster)
    {
        return monster.favoriteFoods.Contains(type);
    }

    // 實現食物被消耗的邏輯
    public void Consume(Monster monster)
    {
        ConsumeEffect(monster);
        // 此處可以添加其他食物被消耗時的邏輯
    }
}

using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using MyGameNamespace;

public class Monster : MonoBehaviour
{
    public float fullness; // 飽食度
    public float maxFullness = 100f; // 最大飽食度
    public List<FoodType> favoriteFoods; // 喜愛的食物類型列表
    public FieldOfView fieldOfView;
    public float eatingDuration = 2f; // 吃食物的持續時間
    public Animator animator; // 假設怪物有 Animator 組件

    void Start()
    {
        if (fieldOfView != null)
        {
            fieldOfView.onFoodDetected += OnFoodDetected;
        }
    }

    void OnFoodDetected(Food food)
    {
        if (CanEat(food))
        {
            MoveToFood(food);
        }
    }

    void MoveToFood(Food food)
    {
        // 實現移動邏輯
        // 到達食物後，呼叫 EatFood(food)
    }

    void EatFood(Food food)
    {
        animator.SetTrigger("Eat");
        StartCoroutine(WaitAndEat(food));
    }

    IEnumerator WaitAndEat(Food food)
    {
        yield return new WaitForSeconds(eatingDuration);
        food.Consume(this); // 吃掉食物並獲得效果
    }

    bool CanEat(Food food)
    {
        return food.IsFavorite(this) && fullness < maxFullness;
    }
}

using UnityEngine;
using MyGameNamespace;

[CreateAssetMenu(fileName = "New Meat", menuName = "Food/Meat")]
public class Meat : Food
{
    public override void ConsumeEffect(Monster monster)
    {
        // 肉類食物的效果，比如增加生命值
    }
}
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using UnityEngine.Events;
using Unity.Mathematics;
[RequireComponent(typeof(ScrollRect))]
public class JoystickDirection : MonoBehaviour
{
    public UnityEvent<Vector2> onValueChanged;

    public InputMaster inputMaster;
    ScrollRect scrollRect;
    public Vector2 currentDirection = Vector2.zero;
    private void Awake()
    {
        inputMaster = new InputMaster();
        inputMaster.Enable();
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }
    private void OnEnable()
    {
        scrollRect = GetComponent<ScrollRect>();
    }

    
    // Update is called once per frame
    void FixedUpdate()
    {
        var keyboardMove = GetKeyboardMove();
        var mobileMove = GetMobineMove();
        
        currentDirection = keyboardMove + mobileMove;
        onValueChanged?.Invoke(currentDirection);
    }

    Vector2 m_keyboardMove = Vector2.zero;
    internal Vector2 GetKeyboardMove()
    {
        m_keyboardMove = Vector2.LerpUnclamped(m_keyboardMove, inputMaster.Player.Movement.ReadValue<Vector2>(), Time.fixedDeltaTime * 10.0f);
        Vector2 vec = m_keyboardMove;
        if (math.abs(vec.x) <= 0.01) { vec.x = 0.0f; }
        if (math.abs(vec.y) <= 0.01) { vec.y = 0.0f; }
        vec = math.float2((vec.x > 0 ? math.ceil(vec.x * 100f) : math.floor(vec.x * 100f)) * 0.01f, (vec.y > 0 ? math.ceil(vec.y * 100f) : math.floor(vec.y * 100f)) * 0.01f);
        return vec;
    }

    internal Vector2 GetMobineMove()
    {
        var localPos = scrollRect.content.localPosition;
        var rectSize = scrollRect.content.rect.size;

        
        float2 pos = math.float2(localPos.x, localPos.y);
        pos = math.clamp(pos, -rectSize, rectSize);
        float2 vec = pos.xy / math.float2(rectSize.x, rectSize.y);
        if (math.abs(vec.x) <= 0.01) { vec.x = 0.0f; }
        if (math.abs(vec.y) <= 0.01) { vec.y = 0.0f; }
        vec = math.float2(math.floor(vec.x * 10f) * 0.1f, math.floor(vec.y * 10f) * 0.1f);
        return vec;
    }
}

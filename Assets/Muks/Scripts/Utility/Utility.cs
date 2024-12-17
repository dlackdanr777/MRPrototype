using System.Text;
using UnityEngine;
using UnityEngine.UI;

public static class Utility
{
    public static string ConvertToMoney(float value)
    {
        string text;

        if (value >= 1_000_000_000) // 10억 이상
        {
            text = (value / 1_000_000_000f).ToString("#,##0.0") + "B"; // 억 단위
        }
        else if (value >= 1_000_000) // 100만 이상
        {
            text = (value / 1_000_000f).ToString("#,##0.0") + "A"; // 백만 단위
        }
        else // 1천 미만
        {
            text = ((int)value).ToString("N0");
        }

        return text;
    }

    /// <summary>총문자열 갯수와 문자열을 받아 문자열 앞쪽에 -를 넣어주는 함수</summary>
    public static string StringAddHyphen(string str, int strLength)
    {
        if (strLength <= str.Length)
            return str;

        StringBuilder strBuilder = new StringBuilder();
        int cnt = strLength - str.Length;

        for(int i = 0; i < cnt; ++i)
            strBuilder.Append("-");

        strBuilder.Append(str);
        return strBuilder.ToString();
    }

    public static string SetStringColor(string str, Color color)
    {
        return "<color=" + ColorToHex(color) + ">" + str + "</color>";
    }


    public static string ColorToHex(Color color)
    {
        int r = Mathf.Clamp(Mathf.FloorToInt(color.r * 255), 0, 255);
        int g = Mathf.Clamp(Mathf.FloorToInt(color.g * 255), 0, 255);
        int b = Mathf.Clamp(Mathf.FloorToInt(color.b * 255), 0, 255);
        return $"#{r:X2}{g:X2}{b:X2}";
    }
}

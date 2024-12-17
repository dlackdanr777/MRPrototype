using System.Text;
using UnityEngine;
using UnityEngine.UI;

public static class Utility
{
    public static string ConvertToMoney(float value)
    {
        string text;

        if (value >= 1_000_000_000) // 10�� �̻�
        {
            text = (value / 1_000_000_000f).ToString("#,##0.0") + "B"; // �� ����
        }
        else if (value >= 1_000_000) // 100�� �̻�
        {
            text = (value / 1_000_000f).ToString("#,##0.0") + "A"; // �鸸 ����
        }
        else // 1õ �̸�
        {
            text = ((int)value).ToString("N0");
        }

        return text;
    }

    /// <summary>�ѹ��ڿ� ������ ���ڿ��� �޾� ���ڿ� ���ʿ� -�� �־��ִ� �Լ�</summary>
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

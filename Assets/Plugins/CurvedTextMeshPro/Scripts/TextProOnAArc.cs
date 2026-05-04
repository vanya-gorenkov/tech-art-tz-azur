using UnityEngine;
using System.Collections;
using TMPro;

namespace ntw.CurvedTextMeshPro
{
    /// <summary>
    /// Class for drawing a Text Pro text following a circle arc
    /// </summary>
    [ExecuteInEditMode]
    public class TextProOnAArc : TextProOnACurve
    {
        /// <summary>
        /// The radius of the text circle arc
        /// </summary>
        [SerializeField]
        [Tooltip("The radius of the text circle arc")]
        private float m_radius = 2000.0f;

        /// <summary>
        /// Previous value of <see cref="m_radius"/>
        /// </summary>
        private float m_oldRadius = float.MaxValue;
        
        [SerializeField]
        [Tooltip("Extra space between lines")]
        private float m_extraLineSpace = 0.0f;
        
        /// <summary>
        /// Previous value of <see cref="m_extraLineSpace"/>
        /// </summary>
        private float m_oldExtraLineSpace = float.MaxValue;

        [SerializeField]
        [Tooltip("Center text align to arc")]
        private bool m_centerTextAlignToArc = true;

        /// <summary>
        /// Previous value of <see cref="m_centerTextAlignToArc"/>
        /// </summary>
        private bool m_oldCenterTextAlignToArc = true;
        
        [SerializeField]
        [Tooltip("Center align to large or small caps (if centered)")]
        private bool m_centerAlignToLargeCaps = true;

        /// <summary>
        /// Previous value of <see cref="m_centerAlignToLargeCaps"/>
        /// </summary>
        private bool m_oldCenterAlignToLargeCaps = true;

        private string m_oldText;

        /// <summary>
        /// Method executed at every frame that checks if some parameters have been changed
        /// </summary>
        /// <returns></returns>
        protected override bool ParametersHaveChanged()
        {
            //check if paramters have changed and update the old values for next frame iteration
            bool retVal = m_radius != m_oldRadius || m_oldCenterTextAlignToArc != m_centerTextAlignToArc || m_oldText != m_TextComponent.text || m_extraLineSpace != m_oldExtraLineSpace || m_centerAlignToLargeCaps != m_oldCenterAlignToLargeCaps;

            m_oldRadius = m_radius;
            m_oldCenterTextAlignToArc = m_centerTextAlignToArc;
            m_oldText = m_TextComponent.text;
            m_oldExtraLineSpace = m_extraLineSpace;
            m_oldCenterAlignToLargeCaps = m_centerAlignToLargeCaps;

            return retVal;
        }

        /// <summary>
        /// Computes the transformation matrix that maps the offsets of the vertices of each single character from
        /// the character's center to the final destinations of the vertices so that the text follows a curve
        /// </summary>
        /// <param name="charMidBaselinePosfloat">Position of the central point of the character</param>
        /// <param name="zeroToOnePos">Horizontal position of the character relative to the bounds of the box, in a range [0, 1]</param>
        /// <param name="textInfo">Information on the text that we are showing</param>
        /// <param name="charIdx">Index of the character we have to compute the transformation for</param>
        /// <returns>Transformation matrix to be applied to all vertices of the text</returns>
        protected override Matrix4x4 ComputeTransformationMatrix(Vector3 charMidBaselinePos, float zeroToOnePos, TMP_TextInfo textInfo, int charIdx)      
        {
            //calculate the actual degrees of the arc considering the size of text
            float actualArcDegrees = textInfo.textComponent.bounds.size.x / (2 * Mathf.PI * m_radius) * 360;

            //compute the angle at which to show this character.
            //We want the string to be centered at the top point of the circle, so we first convert the position from a range [0, 1]
            //to a [-0.5, 0.5] one and then add m_angularOffset degrees, to make it centered on the desired point
            float angle = ((zeroToOnePos - 0.5f) * actualArcDegrees - 90) * Mathf.Deg2Rad; //we need radians for sin and cos

            //compute the coordinates of the new position of the central point of the character. Use sin and cos since we are on a circle.
            //Notice that we have to do some extra calculations because we have to take in count that text may be on multiple lines
            float x0 = Mathf.Cos(angle);
            float y0 = Mathf.Sin(angle);
            float lineHeightWithSpace = textInfo.textComponent.fontSize + m_extraLineSpace;
            float radiusForThisLine = m_radius + lineHeightWithSpace * (textInfo.lineCount - 1 - textInfo.characterInfo[charIdx].lineNumber);
            float textHeightForAdjusting = m_centerAlignToLargeCaps ? textInfo.lineInfo[0].lineHeight: textInfo.textComponent.fontSize;
            
            if (m_centerTextAlignToArc)
            {
                radiusForThisLine -= 0.25f * textHeightForAdjusting + (lineHeightWithSpace * (textInfo.lineCount - 1) / 2);
            }
            Vector2 newMideBaselinePos = new Vector2(x0 * m_radius, -y0 * radiusForThisLine - m_radius); //actual new position of the character

            //compute the trasformation matrix: move the points to the just found position, then rotate the character to fit the angle of the curve 
            //(-90 is because the text is already vertical, it is as if it were already rotated 90 degrees)
            return Matrix4x4.TRS(new Vector3(newMideBaselinePos.x, newMideBaselinePos.y, 0), Quaternion.AngleAxis(-Mathf.Atan2(y0, x0) * Mathf.Rad2Deg - 90, Vector3.forward), Vector3.one);
        }
    }
}

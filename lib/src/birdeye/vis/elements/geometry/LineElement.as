/*  
 * The MIT License
 *
 * Copyright (c) 2008
 * United Nations Office at Geneva
 * Center for Advanced Visual Analytics
 * http://cava.unog.ch
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
 
package birdeye.vis.elements.geometry
{
	import birdeye.vis.data.DataItemLayout;
	import birdeye.vis.guides.renderers.LineRenderer;
	import birdeye.vis.scales.*;
	
	import com.degrafa.IGeometry;
	import com.degrafa.geometry.Line;
	
	import flash.geom.Rectangle;
	
	import mx.collections.CursorBookmark;

	public class LineElement extends CartesianElement
	{
		private var _form:String;
		public function set form(val:String):void
		{
			_form = val;
		}
		
		public function LineElement()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (! itemRenderer)
				itemRenderer = LineRenderer;
		}

		/** @Private 
		 * Called by super.updateDisplayList when the series is ready for layout.*/
		override protected function drawElement():void
		{
			var xPrev:Number, yPrev:Number;
			var xPos:Number, yPos:Number, zPos:Number;
			var j:Number = 0;

			var dataFields:Array = [];
			// prepare data for a standard tooltip message in case the user
			// has not set a dataTipFunction
			dataFields[0] = xField;
			dataFields[1] = yField;
			if (zField) 
				dataFields[2] = zField;

			gg = new DataItemLayout();
			gg.target = this;
			addChild(gg);

			cursor.seek(CursorBookmark.FIRST);
			
			while (!cursor.afterLast)
			{
				if (xAxis)
				{
					xPos = xAxis.getPosition(cursor.current[xField]);
				} else if (chart.xAxis) {
					xPos = chart.xAxis.getPosition(cursor.current[xField]);
				}
				
				if (yAxis)
				{
					yPos = yAxis.getPosition(cursor.current[yField]);
					dataFields[1] = yField;
				} else if (chart.yAxis) {
					yPos = chart.yAxis.getPosition(cursor.current[yField]);
				}
				
				var yAxisRelativeValue:Number = NaN;

				if (zAxis)
				{
					zPos = zAxis.getPosition(cursor.current[zField]);
					yAxisRelativeValue = XYZ(zAxis).height - zPos;
				} else if (chart.zAxis) {
					zPos = chart.zAxis.getPosition(cursor.current[zField]);
					// since there is no method yet to draw a real z axis 
					// we create an y axis and rotate it to properly visualize 
					// a 'fake' z axis. however zPos over this y axis corresponds to 
					// the axis height - zPos, because the y axis in Flex is 
					// up side down. this trick allows to visualize the y axis as
					// if it would be a z. when there will be a 3d line class, it will 
					// be replaced
					yAxisRelativeValue = XYZ(chart.zAxis).height - zPos;
				}

				// yAxisRelativeValue is sent instead of zPos, so that the axis pointer is properly
				// positioned in the 'fake' z axis, which corresponds to a real y axis rotated by 90 degrees
				createTTGG(cursor.current, dataFields, xPos, yPos, yAxisRelativeValue, 3);

				if (zField)
				{
					if (!isNaN(zPos))
					{
						gg = new DataItemLayout();
						gg.target = this;
						graphicsCollection.addItem(gg);
						ttGG.z = gg.z = zPos;
					} else
						zPos = 0;
				}
				
				if (j++ > 0)
				{
					var line:Line = new Line(xPrev,yPrev,xPos,yPos);
					line.fill = fill;
					line.stroke = stroke;
					gg.geometryCollection.addItemAt(line,0);
					line = null;
				}

				if (_showItemRenderer)
				{
	 				var bounds:Rectangle = new Rectangle(xPos - _rendererSize/2, yPos - _rendererSize/2, _rendererSize, _rendererSize);
					var shape:IGeometry = new itemRenderer(bounds);
					shape.fill = fill;
					shape.stroke = stroke;
					gg.geometryCollection.addItem(shape);
				}

				xPrev = xPos; yPrev = yPos;
				if (zField)
				{
					gg.z = zPos;
					if (isNaN(zPos))
						zPos = 0;
				}
				cursor.moveNext();
			}

			if (zField)
				zSort();
		}
 	}
}
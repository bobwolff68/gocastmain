//
//
// gcedit.js
// gocast editor class that uses jquery cleditor plugin
//


"use strict";
/*jslint sloppy: false, todo: true, white: true, browser: true, devel: true */
/*global Callcast, app */

var GoCastJS = ('undefined' !== typeof(GoCastJS)) ? GoCastJS : {};
GoCastJS = (null !== GoCastJS) ? GoCastJS : {};

GoCastJS.gcEdit = function(spot, info)
{
  this.DIV = '<div id="gcEditDiv"><textarea id="gcTextArea"></textarea></div>';
  this.spot = spot;
  this.jqSpot = $(spot);
  this.info = info;
  this.jqDiv = $(this.DIV).appendTo(this.jqSpot).css("position", "absolute");
  this.item = this.jqSpot.data('item');

  this.init();
};

GoCastJS.gcEdit.prototype.init = function()
{
  var self = this;
  this.editor = $("#gcTextArea", this.jqSpot).cleditor(
                  {width:"100%", height:"100%",
                   updateTextArea:function(html)
                   {
                     return self.updateTextArea(html);
                   },
                   updateFrame:function(code)
                   {
                     return self.updateFrame(code);
                   }
                  });
  this.jqSpot.data('gcEdit', this);
  // override mouseover event, prevent showing zoom, trash icons
  // since zooming editor doesn't work yet
  this.jqSpot.mouseover(function(event)
  {
    event.stopPropagation();
    return false;
  });
};
GoCastJS.gcEdit.prototype.updateTextArea = function(html)
{
  console.log("gcEdit.updateTextArea ", html);
  return html;
};
GoCastJS.gcEdit.prototype.updateFrame = function(code)
{
  console.log("gcEdit.updateFrame ", code);
  return code;
};
///
/// \brief rezise the ui object, set css dimensions and scale member var
/// 
/// \arg width, height the target sizes as integers
///
GoCastJS.gcEdit.prototype.setScale = function(width, height)
{
  /*
  var wScale = width/this.width,
      hScale = height/this.height;

  this.scale = (wScale + hScale) / 2; // isotropic, keep aspect ratio
  this.scaleW = wScale;
  this.scaleH = hScale;
  */
  console.log("gcEdit scale width " + width + " height " + height);
  this.jqDiv.width(width).height(height);
};

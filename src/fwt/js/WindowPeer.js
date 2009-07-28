//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   8 May 09  Andy Frank  Creation
//

/**
 * WindowPeer.
 */
fan.fwt.WindowPeer = fan.sys.Obj.$extend(fan.fwt.PanePeer);
fan.fwt.WindowPeer.prototype.$ctor = function(self) {}

fan.fwt.WindowPeer.prototype.open = function(self)
{
  // mount shell we use to attach widgets to
  var shell = document.createElement("div")
  with (shell.style)
  {
    position   = "fixed";
    top        = "0";
    left       = "0";
    width      = "100%";
    height     = "100%";
    background = "#fff";
  }

  // mount window
  var elem = this.emptyDiv();
  shell.appendChild(elem);
  this.attachTo(self, elem);
  document.body.appendChild(shell);
  self.relayout();
}

fan.fwt.WindowPeer.prototype.close = function(self, result)
{
  var event    = fan.fwt.Event.make();
  event.m_id   = fan.fwt.EventId.m_close;
  event.m_data = result;

  var list = self.m_onClose.list();
  for (var i=0; i<list.length; i++) list[i](event);
}

fan.fwt.WindowPeer.prototype.sync = function(self)
{
  var shell = this.elem.parentNode;
  this.size$(this, fan.gfx.Size.make(shell.offsetWidth, shell.offsetHeight));
  fan.fwt.WidgetPeer.prototype.sync.call(this, self);
}

fan.fwt.WindowPeer.prototype.icon = function(self) { return this.m_icon; }
fan.fwt.WindowPeer.prototype.icon$ = function(self, val) { this.m_icon = val; }
fan.fwt.WindowPeer.prototype.m_icon = null;

fan.fwt.WindowPeer.prototype.title = function(self) { return document.title; }
fan.fwt.WindowPeer.prototype.title$ = function(self, val) { document.title = val; }


//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   10 Jun 08  Brian Frank  Creation
//

**
** Window is the base class for widgets which represent
** top level windows.
**
class Window : ContentPane
{

  **
  ** Window mode defines the modal state of the window:
  **   - modeless: no blocking of other windows
  **   - windowModal: input is blocked to parent window
  **   - appModal: input is blocked to all other windows of application
  **   - sysModal: input is blocked to all windows of all applications
  ** The default is modeless.  This field cannot be changed
  ** once the window is constructed.
  **
  const WindowMode mode := WindowMode.modeless

  **
  ** Force window to always be on top of the desktop.  Default
  ** is false.  This field cannot be changed once the window is
  ** constructed.
  **
  const Bool alwaysOnTop := false

  **
  ** Can this window be resizable.  Default is true.  This field
  ** cannot be changed once the window is constructed.
  **
  const Bool resizable := true

  **
  ** Child menu bar widget if top level frame.
  **
  Menu menuBar { set { remove(@menuBar); Widget.super.add(val); @menuBar= val } }

  **
  ** Icon if window is a frame.
  **
  native Image icon

  **
  ** Title string if window is a frame.  Defaults to "".
  **
  native Str title

  **
  ** Open the window.
  **
  native Void open(Window parent := null)

  **
  ** Close the window.
  **
  native Void close()

}
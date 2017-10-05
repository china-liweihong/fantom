//
// Copyright (c) 2015, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   19 Mar 2015  Andy Frank  Creation
//

using dom
using graphics

**************************************************************************
** TreeNode
**************************************************************************

**
** TreeNode models a node in a Tree.
**
** See also: [docDomkit]`docDomkit::Controls#tree`
**
@Js abstract class TreeNode
{
  ** Parent node of this node, or 'null' if this node is a root.
  TreeNode? parent { internal set }

  ** Is this node expanded?
  Bool isExpanded() { expanded }

  ** Return true if this has or might have children. This
  ** is an optimization to display an expansion control
  ** without actually loading all the children.  The
  ** default returns '!children.isEmpty'.
  virtual Bool hasChildren() { !children.isEmpty }

  ** Get the children of this node.  If no children return
  ** an empty list. Default behavior is no children. This
  ** method must return the same instances when called.
  virtual TreeNode[] children() { TreeNode#.emptyList }

  ** Callback to customize Elem for this node.
  abstract Void onElem(Elem elem, TreeFlags flags)

  internal Int? depth
  internal Elem? elem
  internal Bool expanded := false
}

**************************************************************************
** TreeFlags
**************************************************************************

** Tree specific flags for eventing
@Js const class TreeFlags
{
  new make(|This| f) { f(this) }

  ** Tree has focus.
  const Bool focused

  ** Node is selected.
  const Bool selected

  override Str toStr()
  {
    "TreeFlags { focused=$focused; selected=$selected }"
  }
}

**************************************************************************
** TreeEvent
**************************************************************************

**
** TreeEvent are generated by `TreeNode` nodes.
**
@Js class TreeEvent
{
  internal new make(Tree t, TreeNode n, |This| f)
  {
    this.tree = t
    this.node = n
    f(this)
  }

  ** Parent `Tree` instance.
  Tree tree { private set }

  ** `TreeNode` this event was trigged on.
  TreeNode node { private set }

  ** Event type.
  const Str type

  ** Mouse position relative to page.
  const Pos pagePos

  ** Mouse position relative to node.
  const Pos nodePos

  ** Size of node for this event.
  const Size size

  override Str toStr()
  {
    "TreeNode { node=$node type=$type pagePos=$pagePos nodePos=$nodePos size=$size }"
  }
}

**************************************************************************
** Tree
**************************************************************************

**
** Tree visualizes a TreeModel as a series of expandable nodes.
**
** See also: [docDomkit]`docDomkit::Controls#tree`
**
@Js class Tree : Box
{
  ** Constructor.
  new make() : super()
  {
    this.sel = TreeSelection(this)
    this->tabIndex = 0
    this.style.addClass("domkit-Tree domkit-border")

    this.onEvent(EventType.mouseDown,        false) |e| { onMouseEvent(e) }
    this.onEvent(EventType.mouseUp,          false) |e| { onMouseEvent(e) }
    this.onEvent(EventType.mouseDoubleClick, false) |e| { onMouseEvent(e) }

    // manually track focus so we can detect when
    // the browser window becomes unactive while
    // maintaining focus internally in document
    this.onEvent(EventType.focus, false) |e| { manFocus=true;  refresh }
    this.onEvent(EventType.blur,  false) |e| { manFocus=false; refresh }
  }

  ** Root nodes for this tree.
  TreeNode[] roots := [,]

  ** Rebuild tree layout.
  Void rebuild()
  {
    if (this.size.w > 0f) doRebuild
    else Win.cur.setTimeout(16ms) |->| { rebuild }
  }

  ** Refresh tree content.
  Void refresh()
  {
    roots.each |r| { refreshNode(r) }
  }

  ** Refresh given node.
  Void refreshNode(TreeNode node)
  {
    doRefreshNode(node)
  }

  ** Set expanded state for given node.
  Void expand(TreeNode node, Bool expanded)
  {
    // short-cirucit if no-op
    if (node.expanded == expanded) return

    node.expanded = expanded
    refreshNode(node)
  }

  ** Selection for tree. Index based selection is not supported for Tree.
  Selection sel { private set }

  ** Callback when selection changes.
  Void onSelect(|This| f) { cbSelect = f }

  ** Callback when a node has been double clicked.
  Void onAction(|Tree, Event| f) { cbAction = f }

  ** Callback when a event occurs inside a tree node.
  Void onTreeEvent(Str type, |TreeEvent| f) { cbTreeEvent[type] = f }

//////////////////////////////////////////////////////////////////////////
// Layout
//////////////////////////////////////////////////////////////////////////

  private Void doRebuild()
  {
    removeAll
    roots.each |r| { add(toElem(null, r)) }
  }

  private Void doRefreshNode(TreeNode node)
  {
    // TODO: how does this work?
    if (node.elem == null) return

    // update css
    node.elem.style.toggleClass("expanded", node.expanded)

    // set expander icon
    expander := node.elem.querySelector(".domkit-Tree-node-expander")
    expander.style->left = "${node.depth * depthIndent}px"
    expander.html = node.hasChildren ? "\u25ba" : "&nbsp;"

    // remove existing children
    while (node.elem.children.size > 1)
      node.elem.remove(node.elem.lastChild)

    // update selection
    selected := sel.items.contains(node)
    content  := node.elem.querySelector(".domkit-Tree-node")
    content.style.toggleClass("domkit-sel", selected)

    // update content
    flags := TreeFlags
    {
      it.focused  = manFocus
      it.selected = selected
    }
    content.style->paddingLeft = "${(node.depth+1) * depthIndent}px"
    node.onElem(content.lastChild, flags)

    // add children if expanded
    if (node.expanded)
    {
      node.children.each |k|
      {
        k.parent = node
        node.elem.add(toElem(node, k))
        doRefreshNode(k)
      }
    }
  }

  ** Map TreeNode to DOM element.
  private Elem toElem(TreeNode? parent, TreeNode node)
  {
    if (node.elem == null)
    {
      node.depth = parent==null ? 0 : parent.depth+1
      node.elem = Elem
      {
        it.style.addClass("domkit-Tree-node-block")
        Elem {
          it.style.addClass("domkit-Tree-node")
          Elem { it.style.addClass("domkit-Tree-node-expander") },
          Elem {},
        },
      }
      refreshNode(node)
    }
    return node.elem
  }

  ** Map DOM element to TreeNode.
  private TreeNode toNode(Elem elem)
  {
    // bubble to block elem
    while (!elem.style.hasClass("domkit-Tree-node-block")) elem = elem.parent

    // find dom path
    elemPath := Elem[elem]
    while (!elemPath.first.parent.style.hasClass("domkit-Tree"))
      elemPath.insert(0, elemPath.first.parent)

    // walk path from roots
    TreeNode? node
    elemPath.each |p|
    {
      i := p.parent.children.findIndex |k| { p == k }
      node = node==null ? roots[i] : node.children[i-1]
    }

    return node
  }

//////////////////////////////////////////////////////////////////////////
// Eventing
//////////////////////////////////////////////////////////////////////////

  private Void onMouseEvent(Event e)
  {
    elem := e.target
    if (elem == this) return
    node := toNode(elem)

    // check expand/selection
    if (e.type == EventType.mouseUp)
    {
      if (elem.style.hasClass("domkit-Tree-node-expander"))
      {
        // expand node
        expand(node, !node.expanded)
      }
      else
      {
        // update selection
        if (!sel.items.contains(node))
        {
          sel.item = node
          cbSelect?.call(this)
        }
      }
    }

    // check action
    if (e.type == EventType.mouseDoubleClick) cbAction?.call(this, e)

    // delegate to cell handlers
    cb := cbTreeEvent[e.type]
    if (cb != null)
    {
      blockElem := node.elem
      nodeElem  := blockElem.firstChild
      indent    := (node.depth + 1) * depthIndent
      npos      := e.pagePos.rel(nodeElem)

      // outside of content
      if (npos.x - indent < 0) return

      cb.call(TreeEvent(this, node) {
        it.type    = e.type
        it.pagePos = e.pagePos
        it.nodePos = Pos(npos.x-indent, npos.y)
        it.size    = Size(nodeElem.size.w-indent, nodeElem.size.h)
      })
    }
  }

//////////////////////////////////////////////////////////////////////////
// Selection
//////////////////////////////////////////////////////////////////////////

  internal Void onUpdateSel(TreeNode[] oldNodes, TreeNode[] newNodes)
  {
    oldNodes.each |n| { refreshNode(n) }
    newNodes.each |n| { refreshNode(n) }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private static const Int depthIndent := 16

  private TreeNode[] nodes := [,]
  private Func? cbSelect
  private Func? cbAction
  private Str:Func cbTreeEvent := [:]

  // focus/blur
  private Bool manFocus := false
}

**************************************************************************
** TreeSelection
**************************************************************************

@Js internal class TreeSelection : Selection
{
  new make(Tree tree) { this.tree = tree }

  override Bool isEmpty() { items.isEmpty }

  override Int size() { items.size }

  override Obj? item
  {
    get { items.first }
    set { items = (it == null) ? Obj[,] : [it] }
  }

  override Obj[] items := [,]
  {
    set
    {
      if (!enabled) return
      oldItems := &items
      newItems := (multi ? it : (it.size > 0 ? [it.first] : Obj[,])).ro
      &items = newItems
      tree.onUpdateSel(oldItems, newItems)
    }
  }

  // TODO: unless we can make index meaningful/useful and performant
  // its probably better to fail fast so its not used

  override Int? index
  {
    get { throw Err("Not implemented for Tree") }
    set { throw Err("Not implemented for Tree") }
  }

  override Int[] indexes
  {
    get { throw Err("Not implemented for Tree") }
    set { throw Err("Not implemented for Tree") }
  }

  private Tree tree
}
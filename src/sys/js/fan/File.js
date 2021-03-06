//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   29 Mar 09  Andy Frank  Creation
//

/**
 * File.
 */
fan.sys.File = fan.sys.Obj.$extend(fan.sys.Obj);

fan.sys.File.prototype.$ctor = function() {}
fan.sys.File.prototype.$typeof = function() { return fan.sys.File.$type; }

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

fan.sys.File.make = function(uri, checkSlash)
{
  if (checkSlash === undefined) checkSlash = true;

  // TODO
  // // if running under rhino, return local instance
  // if (fan.sys.Env.$nodejs)
  // {
  //   var f = fan.sys.LocalFile.uriToFile(uri);
  //   if (f.isDirectory() && !checkSlash && !uri.isDir())
  //     uri = uri.plusSlash();
  //   return fan.sys.LocalFile.makeUri(uri, f);
  // }

  // TODO FIXIT: for now return "empty" instance
  var f = new fan.sys.File();
  f.m_uri = uri;
  return f;
}

fan.sys.File.os = function(osPath)
{
  // TODO
  // // if running under rhino, return local instance
  // if (fan.sys.Env.$nodejs)
  //   return fan.sys.LocalFile.make(new java.io.File(osPath));

  // TODO FIXIT: for now return "empty" instance
  return new fan.sys.File();
}

//////////////////////////////////////////////////////////////////////////
// File
//////////////////////////////////////////////////////////////////////////

fan.sys.File.prototype.exists = function() { return true; }

fan.sys.File.prototype.uri = function() { return this.m_uri; }

//
// Copyright (c) 2015, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   25 Sep 2015  Andy Frank  Creation
//

**
** GeomTest
**
@Js
class GeomTest : Test
{

  Void testPos()
  {
    verifyEq(Pos.defVal, Pos(0, 0))
    verifyEq(Pos#.make, Pos(0, 0))

    verifyEq(Pos(3, 4), Pos(3, 4))
    verifyNotEq(Pos(3, 9), Pos(3, 4))
    verifyNotEq(Pos(9, 4), Pos(3, 4))

    verifyEq(Pos.fromStr("4,-2"), Pos(4, -2))
    verifyEq(Pos.fromStr("33 , 44"), Pos(33, 44))
    verifyEq(Pos.fromStr("x,-2", false), null)
    verifyErr(ParseErr#) { x := Pos.fromStr("x,-2") }
    verifyErr(ParseErr#) { x := Pos.fromStr("x,-2", true) }

    verifyEq(Pos(0,0).translate(5,7),   Pos(5,7))
    verifyEq(Pos(3,8).translate(-2,-5), Pos(1,3))
    verifyEq(Pos(0,0).translatePos(Pos(5,7)),   Pos(5,7))
    verifyEq(Pos(3,8).translatePos(Pos(-2,-5)), Pos(1,3))

    verifySer(Pos(0, 1))
    verifySer(Pos(-99, -505))
  }

  Void testSize()
  {
    verifyEq(Size.defVal, Size(0, 0))
    verifyEq(Size#.make, Size(0, 0))

    verifyEq(Size(3, 4), Size(3, 4))
    verifyNotEq(Size(3, 9), Size(3, 4))
    verifyNotEq(Size(9, 4), Size(3, 4))

    verifyEq(Size.fromStr("4,-2"), Size(4, -2))
    verifyEq(Size.fromStr("-33 , 60"), Size(-33, 60))
    verifyEq(Size.fromStr("x,-2", false), null)
    verifyErr(ParseErr#) { x := Size.fromStr("x,-2") }
    verifyErr(ParseErr#) { x := Size.fromStr("x,-2", true) }

    verifySer(Size(0, 1))
    verifySer(Size(-99, -505))
  }

  Void verifySer(Obj obj)
  {
    //echo("-- " + Buf.make.writeObj(obj).flip.readAllStr)
    x := Buf.make.writeObj(obj).flip.readObj
    verifyEq(obj, x)
  }
}